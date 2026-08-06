ARG DEBIAN_TAG=bookworm
FROM debian:${DEBIAN_TAG}

ARG LOCALE=en-US-x-icu
ARG EXPECTED_MD5
ARG ENGINE=icu
ARG DEBIAN_TAG

ENV TEST_LOCALE=${LOCALE}
ENV EXPECTED_MD5=${EXPECTED_MD5}
ENV TEST_ENGINE=${ENGINE}
ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

RUN ulimit -n 1024 \
    && apt_sources=/etc/apt/sources.list \
    && apt_update_options= \
    && apt_install_options= \
    && case "${DEBIAN_TAG}" in \
         7|8|9|10) \
           sed -i \
             -e 's|deb.debian.org/debian|archive.debian.org/debian|g' \
             -e 's|security.debian.org/debian-security|archive.debian.org/debian-security|g' \
             -e '/-updates/d' \
           "${apt_sources}" \
           && apt_update_options='-o Acquire::Check-Valid-Until=false' \
           && apt_install_options='--force-yes' \
           ;; \
       esac \
    && apt-get ${apt_update_options} update \
    && apt-get ${apt_install_options} install -y --no-install-recommends \
        ca-certificates \
        curl \
        locales \
        libicu-dev \
    && sed -i -E 's/^# *((en_US|ja_JP|zh_CN|ko_KR|ru_RU|fr_FR|de_DE|es_ES|ar_SA)\.UTF-8 UTF-8)$/\1/' /etc/locale.gen \
    && locale-gen \
    && mkdir -p /etc/postgresql-common \
    && echo "initdb_options = '--encoding=UTF8 --locale=en_US.UTF-8'" > /etc/postgresql-common/createcluster.conf \
    && apt-get ${apt_install_options} install -y --no-install-recommends \
        postgresql \
        postgresql-client \
    && rm -rf /var/lib/apt/lists/*

COPY unicode-sorting.sql unicode-sorting-md5.sql /opt/unicode-sorting/

WORKDIR /opt/unicode-sorting

CMD set -eu; \
    test_started="$(date +%s)"; \
    libc_version="$(dpkg-query -W -f='${Version}' libc6 2>/dev/null || true)"; \
    icu_version="$(dpkg-query -W -f='${Version}' libicu-dev 2>/dev/null || true)"; \
    pg_cluster="$(pg_lsclusters -h | awk 'NR == 1 {print $1, $2}')"; \
    pg_ctlcluster ${pg_cluster} start; \
    if su postgres -c "psql -Atqc \"SELECT 1 FROM pg_settings WHERE name = 'max_parallel_workers_per_gather'\"" | grep -q 1; then \
      su postgres -c "psql -v ON_ERROR_STOP=1 -c \"ALTER SYSTEM SET max_parallel_workers_per_gather = 0;\""; \
      pg_ctlcluster ${pg_cluster} reload; \
    fi; \
    curl -ks "https://www.unicode.org/Public/15.0.0/ucd/UnicodeData.txt" | cut -d';' -f1-3 > /opt/unicode-sorting/UnicodeData.txt; \
    chmod 644 /opt/unicode-sorting/UnicodeData.txt; \
    if [ "${TEST_ENGINE}" = glibc ]; then \
      su postgres -c "psql -v ON_ERROR_STOP=1 -c \"CREATE COLLATION \\\"${TEST_LOCALE}\\\" (locale = '${TEST_LOCALE}');\"" || true; \
    fi; \
    su postgres -c "psql -v ON_ERROR_STOP=1 -v UNICODE_VERS=15 -v UNICODE_FILE=/opt/unicode-sorting/UnicodeData.txt -c \"SET work_mem = '3GB';\" -f /opt/unicode-sorting/unicode-sorting.sql"; \
    sed "s/@LOCALE@/\\\"${TEST_LOCALE}\\\"/g" /opt/unicode-sorting/unicode-sorting-md5.sql > /tmp/unicode-sorting-md5.sql; \
    su postgres -c "psql -At -v ON_ERROR_STOP=1 -f /tmp/unicode-sorting-md5.sql" | tee /tmp/unicode-sorting-md5-output; \
    result="$(sed -n 's/^[0-9a-f][0-9a-f]*$/&/p' /tmp/unicode-sorting-md5-output | tail -1)"; \
    echo "locale=${TEST_LOCALE} md5=${result} expected=${EXPECTED_MD5}"; \
    echo "libc_version=${libc_version} icu_version=${icu_version} test_runtime_seconds=$(( $(date +%s) - test_started ))"; \
    if [ -n "${EXPECTED_MD5}" ]; then \
      test "${result}" = "${EXPECTED_MD5}"; \
    else \
      echo 'No expected MD5 supplied; checksum was not compared'; \
      exit 2; \
    fi
