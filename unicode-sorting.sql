\timing

drop table if exists unicode_spec;
create table unicode_spec(f1 text,f2 text,f3 text);

copy unicode_spec from :'UNICODE_FILE' with (delimiter ';');

drop table if exists unicode_data;
create table unicode_data(d1 text);

create or replace function insert_codepoint(cp int) returns int as $$
  begin
    insert into unicode_data values( chr(cp) );   -- 199

    insert into unicode_data values( chr(cp)||'B' );   -- 200
    insert into unicode_data values( chr(cp)||'O' );   -- 201
    insert into unicode_data values( chr(cp)||'3' );   -- 202
    insert into unicode_data values( chr(cp)||'.' );   -- 203
    insert into unicode_data values( chr(cp)||' ' );   -- 204
    insert into unicode_data values( chr(cp)||'様' );   -- 205
    insert into unicode_data values( chr(cp)||'ク' );   -- 206
    insert into unicode_data values( 'B'||chr(cp) );   -- 210
    insert into unicode_data values( 'O'||chr(cp) );   -- 211
    insert into unicode_data values( '3'||chr(cp) );   -- 212
    insert into unicode_data values( '.'||chr(cp) );   -- 213
    insert into unicode_data values( ' '||chr(cp) );   -- 214
    insert into unicode_data values( '様'||chr(cp) );   -- 215
    insert into unicode_data values( 'ク'||chr(cp) );   -- 216
    insert into unicode_data values( chr(cp)||chr(cp) );   -- 299

    insert into unicode_data values( chr(cp)||'BB' );   -- 300
    insert into unicode_data values( chr(cp)||'OO' );   -- 301
    insert into unicode_data values( chr(cp)||'33' );   -- 302
    insert into unicode_data values( chr(cp)||'..' );   -- 303
    insert into unicode_data values( chr(cp)||'  ' );   -- 304
    insert into unicode_data values( chr(cp)||'様様' );   -- 305
    insert into unicode_data values( chr(cp)||'クク' );   -- 306
    insert into unicode_data values( 'B'||chr(cp)||'B' );   -- 310
    insert into unicode_data values( 'O'||chr(cp)||'O' );   -- 311
    insert into unicode_data values( '3'||chr(cp)||'3' );   -- 312
    insert into unicode_data values( '.'||chr(cp)||'.' );   -- 313
    insert into unicode_data values( ' '||chr(cp)||' ' );   -- 314
    insert into unicode_data values( '様'||chr(cp)||'様' );   -- 315
    insert into unicode_data values( 'ク'||chr(cp)||'ク' );   -- 316
    insert into unicode_data values( 'BB'||chr(cp) );   -- 320
    insert into unicode_data values( 'OO'||chr(cp) );   -- 321
    insert into unicode_data values( '33'||chr(cp) );   -- 322
    insert into unicode_data values( '..'||chr(cp) );   -- 323
    insert into unicode_data values( '  '||chr(cp) );   -- 324
    insert into unicode_data values( '様様'||chr(cp) );   -- 325
    insert into unicode_data values( 'クク'||chr(cp) );   -- 326
    insert into unicode_data values( chr(cp)||chr(cp)||'B' );   -- 330
    insert into unicode_data values( chr(cp)||chr(cp)||'O' );   -- 331
    insert into unicode_data values( chr(cp)||chr(cp)||'3' );   -- 332
    insert into unicode_data values( chr(cp)||chr(cp)||'.' );   -- 333
    insert into unicode_data values( chr(cp)||chr(cp)||' ' );   -- 334
    insert into unicode_data values( chr(cp)||chr(cp)||'様' );   -- 335
    insert into unicode_data values( chr(cp)||chr(cp)||'ク' );   -- 336
    insert into unicode_data values( chr(cp)||'B'||chr(cp) );   -- 340
    insert into unicode_data values( chr(cp)||'O'||chr(cp) );   -- 341
    insert into unicode_data values( chr(cp)||'3'||chr(cp) );   -- 342
    insert into unicode_data values( chr(cp)||'.'||chr(cp) );   -- 343
    insert into unicode_data values( chr(cp)||' '||chr(cp) );   -- 344
    insert into unicode_data values( chr(cp)||'様'||chr(cp) );   -- 345
    insert into unicode_data values( chr(cp)||'ク'||chr(cp) );   -- 346
    insert into unicode_data values( 'B'||chr(cp)||chr(cp) );   -- 350
    insert into unicode_data values( 'O'||chr(cp)||chr(cp) );   -- 351
    insert into unicode_data values( '3'||chr(cp)||chr(cp) );   -- 352
    insert into unicode_data values( '.'||chr(cp)||chr(cp) );   -- 353
    insert into unicode_data values( ' '||chr(cp)||chr(cp) );   -- 354
    insert into unicode_data values( '様'||chr(cp)||chr(cp) );   -- 355
    insert into unicode_data values( 'ク'||chr(cp)||chr(cp) );   -- 356
    insert into unicode_data values( '3B'||chr(cp) );   -- 380
    insert into unicode_data values( chr(cp)||chr(cp)||chr(cp) );   -- 399

    insert into unicode_data values( chr(cp)||chr(cp)||'BB' );   -- 400
    insert into unicode_data values( chr(cp)||chr(cp)||'OO' );   -- 401
    insert into unicode_data values( chr(cp)||chr(cp)||'33' );   -- 402
    insert into unicode_data values( chr(cp)||chr(cp)||'..' );   -- 403
    insert into unicode_data values( chr(cp)||chr(cp)||'  ' );   -- 404
    insert into unicode_data values( chr(cp)||chr(cp)||'様様' );   -- 405
    insert into unicode_data values( chr(cp)||chr(cp)||'クク' );   -- 406
    insert into unicode_data values( 'B'||chr(cp)||chr(cp)||'B' );   -- 410
    insert into unicode_data values( 'O'||chr(cp)||chr(cp)||'O' );   -- 411
    insert into unicode_data values( '3'||chr(cp)||chr(cp)||'3' );   -- 412
    insert into unicode_data values( '.'||chr(cp)||chr(cp)||'.' );   -- 413
    insert into unicode_data values( ' '||chr(cp)||chr(cp)||' ' );   -- 414
    insert into unicode_data values( '様'||chr(cp)||chr(cp)||'様' );   -- 415
    insert into unicode_data values( 'ク'||chr(cp)||chr(cp)||'ク' );   -- 416
    insert into unicode_data values( 'BB'||chr(cp)||chr(cp) );   -- 420
    insert into unicode_data values( 'OO'||chr(cp)||chr(cp) );   -- 421
    insert into unicode_data values( '33'||chr(cp)||chr(cp) );   -- 422
    insert into unicode_data values( '..'||chr(cp)||chr(cp) );   -- 423
    insert into unicode_data values( '  '||chr(cp)||chr(cp) );   -- 424
    insert into unicode_data values( '様様'||chr(cp)||chr(cp) );   -- 425
    insert into unicode_data values( 'クク'||chr(cp)||chr(cp) );   -- 426
    insert into unicode_data values( '3B'||chr(cp)||'B' );   -- 480
    insert into unicode_data values( '3B-'||chr(cp) );   -- 481
    insert into unicode_data values( chr(cp)||chr(cp)||chr(cp)||chr(cp) );   -- 499

    insert into unicode_data values( 'BB'||chr(cp)||chr(cp)||'' );   -- 580
    insert into unicode_data values( 'BB'||chr(cp)||chr(cp) );   -- 581
    insert into unicode_data values( 'BB-'||chr(cp)||chr(cp) );   -- 582
    insert into unicode_data values( '🙂👍'||chr(cp)||'❤™' );   -- 583
    insert into unicode_data values( chr(cp)||chr(cp)||'.33' );   -- 584
    insert into unicode_data values( '3B-'||chr(cp)||'B' );   -- 585
    insert into unicode_data values( chr(cp)||chr(cp)||chr(cp)||chr(cp)||chr(cp) );   -- 599

    return null;
  end;
$$ language plpgsql;

do $$
  declare
    t1 text; t2 text; t3 text;
    first int; last int;
  begin
    for t1,t2,t3 in select * from unicode_spec loop
      continue when t2='<control>';
      continue when t3='Cs';
      if t2 like '% First>' then first=('x'||lpad(t1, 8, '0'))::bit(32)::int; continue; end if;
      if t2 like '% Last>' then
        last=('x'||lpad(t1, 8, '0'))::bit(32)::int;
        for i in first..last loop perform insert_codepoint(i); end loop;
        continue;
      end if;
      perform insert_codepoint(('x'||lpad(t1, 8, '0'))::bit(32)::int);
    end loop;
  end;
$$;
