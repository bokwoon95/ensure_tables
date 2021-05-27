DROP TABLE IF EXISTS payment CASCADE;
DROP TABLE IF EXISTS rental CASCADE;
DROP TABLE IF EXISTS inventory CASCADE;
DROP TABLE IF EXISTS customer CASCADE;
DROP TABLE IF EXISTS store CASCADE;
DROP TABLE IF EXISTS staff CASCADE;
DROP TABLE IF EXISTS film_category CASCADE;
DROP TABLE IF EXISTS film_actor CASCADE;
DROP TABLE IF EXISTS film CASCADE;
DROP TABLE IF EXISTS language CASCADE;
DROP TABLE IF EXISTS address CASCADE;
DROP TABLE IF EXISTS city CASCADE;
DROP TABLE IF EXISTS country CASCADE;
DROP TABLE IF EXISTS category CASCADE;
DROP TABLE IF EXISTS actor CASCADE;
DROP TYPE IF EXISTS mpaa_rating CASCADE;
DROP DOMAIN IF EXISTS year CASCADE;
DROP FUNCTION IF EXISTS last_updated_trg;

CREATE FUNCTION last_updated_trg() RETURNS trigger AS $$ BEGIN
    NEW.last_update = NOW();
    RETURN NEW;
END $$ LANGUAGE plpgsql;

CREATE DOMAIN year AS INT CONSTRAINT year_check CHECK (VALUE >= 1901 AND VALUE <= 2155);

CREATE TYPE mpaa_rating AS ENUM ('G', 'PG', 'PG-13', 'R', 'NC-17');

CREATE TABLE actor (
    actor_id INT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY
    ,first_name TEXT NOT NULL
    ,last_name TEXT NOT NULL
    ,full_name TEXT GENERATED ALWAYS AS (first_name || ' ' || last_name) STORED
    ,full_name_reversed TEXT GENERATED ALWAYS AS (last_name || ' ' || first_name) STORED
    ,last_update TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

CREATE INDEX actor_last_name_idx ON actor USING btree (last_name);

CREATE TRIGGER actor_last_updated_before_update_trg BEFORE UPDATE ON actor FOR EACH ROW EXECUTE PROCEDURE last_updated_trg();

CREATE TABLE category (
    category_id SERIAL PRIMARY KEY
    ,name TEXT NOT NULL
    ,last_update TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

CREATE TRIGGER category_last_updated_before_update_trg BEFORE UPDATE ON category FOR EACH ROW EXECUTE PROCEDURE last_updated_trg();

CREATE TABLE country (
    country_id INT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY
    ,country TEXT NOT NULL
    ,last_update TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

CREATE TRIGGER country_last_updated_before_update_trg BEFORE UPDATE ON country FOR EACH ROW EXECUTE PROCEDURE last_updated_trg();

CREATE TABLE city (
    city_id INT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY
    ,city TEXT NOT NULL
    ,country_id INT NOT NULL
    ,last_update TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

ALTER TABLE city ADD CONSTRAINT city_country_id_fkey FOREIGN KEY (country_id) REFERENCES country (country_id) ON UPDATE CASCADE ON DELETE RESTRICT;

CREATE INDEX city_country_id_idx ON city USING btree (country_id);

CREATE TRIGGER city_last_updated_before_update_trg BEFORE UPDATE ON city FOR EACH ROW EXECUTE PROCEDURE last_updated_trg();

CREATE TABLE address (
    address_id INT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY
    ,address TEXT NOT NULL
    ,address2 TEXT
    ,district TEXT NOT NULL
    ,city_id INT NOT NULL
    ,postal_code TEXT
    ,phone TEXT NOT NULL
    ,last_update TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

ALTER TABLE address ADD CONSTRAINT address_city_id_fkey FOREIGN KEY (city_id) REFERENCES city (city_id) ON UPDATE CASCADE ON DELETE RESTRICT;

CREATE INDEX address_city_id_idx ON address USING btree (city_id);

CREATE TRIGGER address_last_updated_before_update_trg BEFORE UPDATE ON address FOR EACH ROW EXECUTE PROCEDURE last_updated_trg();

CREATE TABLE language (
    language_id INT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY
    ,name TEXT NOT NULL
    ,last_update TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

CREATE TRIGGER language_last_updated_before_update_trg BEFORE UPDATE ON language FOR EACH ROW EXECUTE PROCEDURE last_updated_trg();

CREATE TABLE film (
    film_id INT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY
    ,title TEXT NOT NULL
    ,description TEXT
    ,release_year year
    ,language_id INT NOT NULL
    ,original_language_id INT
    ,rental_duration INT DEFAULT 3 NOT NULL
    ,rental_rate DECIMAL(4,2) DEFAULT 4.99 NOT NULL
    ,length INT
    ,replacement_cost DECIMAL(5,2) DEFAULT 19.99 NOT NULL
    ,rating mpaa_rating DEFAULT 'G'::mpaa_rating
    ,special_features TEXT[]
    ,last_update TIMESTAMPTZ DEFAULT NOW() NOT NULL
    ,fulltext TSVECTOR NOT NULL
);

ALTER TABLE film ADD CONSTRAINT film_language_id_fkey FOREIGN KEY (language_id) REFERENCES language (language_id) ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE film ADD CONSTRAINT film_original_language_id_fkey FOREIGN KEY (original_language_id) REFERENCES language (language_id) ON UPDATE CASCADE ON DELETE RESTRICT;

CREATE INDEX film_title_idx ON film USING btree (title);

CREATE INDEX film_language_id_idx ON film USING btree (language_id);

CREATE INDEX film_original_language_id_idx ON film USING btree (original_language_id);

CREATE INDEX film_fulltext_idx ON film USING gist (fulltext);

CREATE TRIGGER film_last_updated_before_update_trg BEFORE UPDATE ON film FOR EACH ROW EXECUTE PROCEDURE last_updated_trg();

CREATE TRIGGER film_fulltext_before_insert_update_trg BEFORE INSERT OR UPDATE ON film FOR EACH ROW EXECUTE PROCEDURE tsvector_update_trigger('fulltext', 'pg_catalog.english', 'title', 'description');

CREATE TABLE film_actor (
    actor_id INT NOT NULL
    ,film_id INT NOT NULL
    ,last_update TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

ALTER TABLE film_actor ADD CONSTRAINT film_actor_actor_id_fkey FOREIGN KEY (actor_id) REFERENCES actor (actor_id) ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE film_actor ADD CONSTRAINT film_actor_film_id_fkey FOREIGN KEY (film_id) REFERENCES film (film_id) ON UPDATE CASCADE ON DELETE RESTRICT;

CREATE UNIQUE INDEX film_actor_actor_id_film_id_idx ON film_actor USING btree (actor_id, film_id);

CREATE INDEX film_actor_film_id_idx ON film_actor USING btree (film_id);

CREATE TRIGGER film_actor_last_updated_before_update_trg BEFORE UPDATE ON film_actor FOR EACH ROW EXECUTE PROCEDURE last_updated_trg();

CREATE TABLE film_category (
    film_id INT NOT NULL
    ,category_id INT NOT NULL
    ,last_update TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

ALTER TABLE film_category ADD CONSTRAINT film_category_category_id_fkey FOREIGN KEY (category_id) REFERENCES category (category_id) ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE film_category ADD CONSTRAINT film_category_film_id_fkey FOREIGN KEY (film_id) REFERENCES film (film_id) ON UPDATE CASCADE ON DELETE RESTRICT;

CREATE TRIGGER film_category_last_updated_before_update_trg BEFORE UPDATE ON film_category FOR EACH ROW EXECUTE PROCEDURE last_updated_trg();

CREATE TABLE staff (
    staff_id INT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY
    ,first_name TEXT NOT NULL
    ,last_name TEXT NOT NULL
    ,address_id INT NOT NULL
    ,email TEXT
    ,store_id INT
    ,active BOOLEAN DEFAULT TRUE NOT NULL
    ,username TEXT NOT NULL
    ,password TEXT
    ,last_update TIMESTAMPTZ DEFAULT NOW() NOT NULL
    ,picture BYTEA
);

ALTER TABLE staff ADD CONSTRAINT staff_address_id_fkey FOREIGN KEY (address_id) REFERENCES address (address_id) ON UPDATE CASCADE ON DELETE RESTRICT;

CREATE TRIGGER staff_last_updated_before_update_trg BEFORE UPDATE ON staff FOR EACH ROW EXECUTE PROCEDURE last_updated_trg();

CREATE TABLE store (
    store_id INT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY
    ,manager_staff_id INT NOT NULL UNIQUE
    ,address_id INT NOT NULL
    ,last_update TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

ALTER TABLE staff ADD CONSTRAINT staff_store_id_fkey FOREIGN KEY (store_id) REFERENCES store (store_id);

ALTER TABLE store ADD CONSTRAINT store_address_id_fkey FOREIGN KEY (address_id) REFERENCES address (address_id) ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE store ADD CONSTRAINT store_manager_staff_id_fkey FOREIGN KEY (manager_staff_id) REFERENCES staff (staff_id) ON UPDATE CASCADE ON DELETE RESTRICT;

CREATE TRIGGER store_last_updated_before_update_trg BEFORE UPDATE ON store FOR EACH ROW EXECUTE PROCEDURE last_updated_trg();

CREATE TABLE customer (
    customer_id INT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY
    ,store_id INT NOT NULL
    ,first_name TEXT NOT NULL
    ,last_name TEXT NOT NULL
    ,email TEXT UNIQUE
    ,address_id INT NOT NULL
    ,active BOOLEAN DEFAULT TRUE NOT NULL
    ,data JSONB
    ,create_date TIMESTAMPTZ DEFAULT NOW() NOT NULL
    ,last_update TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE customer ADD CONSTRAINT customer_email_first_name_last_name_key UNIQUE (email, first_name, last_name);

ALTER TABLE customer ADD CONSTRAINT customer_address_id_fkey FOREIGN KEY (address_id) REFERENCES address (address_id) ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE customer ADD CONSTRAINT customer_store_id_fkey FOREIGN KEY (store_id) REFERENCES store (store_id) ON UPDATE CASCADE ON DELETE RESTRICT;

CREATE INDEX customer_address_id_idx ON customer USING btree (address_id);

CREATE INDEX customer_store_id_idx ON customer USING btree (store_id);

CREATE INDEX customer_last_name_idx ON customer USING btree (last_name);

CREATE INDEX customer_email_gmail_idx ON customer (email) WHERE email LIKE '%@gmail.com';

CREATE INDEX customer_customer_id_data_age_idx ON customer (customer_id, ((data->>'age')::INT));

CREATE TRIGGER customer_last_updated_before_update_trg BEFORE UPDATE ON customer FOR EACH ROW EXECUTE PROCEDURE last_updated_trg();

CREATE TABLE inventory (
    inventory_id INT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY
    ,film_id INT NOT NULL
    ,store_id INT NOT NULL
    ,last_update TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

ALTER TABLE inventory ADD CONSTRAINT inventory_film_id_fkey FOREIGN KEY (film_id) REFERENCES film (film_id) ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE inventory ADD CONSTRAINT inventory_store_id_fkey FOREIGN KEY (store_id) REFERENCES store (store_id) ON UPDATE CASCADE ON DELETE RESTRICT;

CREATE INDEX inventory_store_id_film_id_idx ON inventory USING btree (store_id, film_id);

CREATE TRIGGER inventory_last_updated_before_update_trg BEFORE UPDATE ON inventory FOR EACH ROW EXECUTE PROCEDURE last_updated_trg();

CREATE TABLE rental (
    rental_id INT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY
    ,rental_date TIMESTAMPTZ NOT NULL
    ,inventory_id INT NOT NULL
    ,customer_id INT NOT NULL
    ,return_date TIMESTAMPTZ
    ,staff_id INT NOT NULL
    ,last_update TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

ALTER TABLE rental ADD CONSTRAINT rental_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES customer (customer_id) ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE rental ADD CONSTRAINT rental_inventory_id_fkey FOREIGN KEY (inventory_id) REFERENCES inventory (inventory_id) ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE rental ADD CONSTRAINT rental_staff_id_fkey FOREIGN KEY (staff_id) REFERENCES staff (staff_id) ON UPDATE CASCADE ON DELETE RESTRICT;

CREATE UNIQUE INDEX rental_rental_date_inventory_id_customer_id_idx ON rental USING btree (rental_date, inventory_id, customer_id);

CREATE INDEX rental_inventory_id_idx ON rental (inventory_id);

CREATE INDEX rental_customer_id_idx ON rental (customer_id);

CREATE INDEX rental_staff_id_idx ON rental (staff_id);

CREATE TRIGGER rental_last_updated_before_update_trg BEFORE UPDATE ON rental FOR EACH ROW EXECUTE PROCEDURE last_updated_trg();

CREATE TABLE payment (
    payment_id INT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY
    ,customer_id INT NOT NULL
    ,staff_id INT NOT NULL
    ,rental_id INT
    ,amount DECIMAL(5,2) NOT NULL
    ,payment_date TIMESTAMPTZ NOT NULL
);

ALTER TABLE payment ADD CONSTRAINT payment_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES customer (customer_id) ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE payment ADD CONSTRAINT payment_rental_id_fkey FOREIGN KEY (rental_id) REFERENCES rental (rental_id) ON UPDATE CASCADE ON DELETE SET NULL;

ALTER TABLE payment ADD CONSTRAINT payment_staff_id_fkey FOREIGN KEY (staff_id) REFERENCES staff (staff_id) ON UPDATE CASCADE ON DELETE RESTRICT;

CREATE INDEX payment_customer_id_idx ON payment USING btree (customer_id);

CREATE INDEX payment_staff_id_idx ON payment USING btree (staff_id);
