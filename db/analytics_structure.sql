SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: logged_searches; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.logged_searches (
    id bigint NOT NULL,
    request_at timestamp without time zone,
    request_id uuid,
    log_line text,
    endpoint integer,
    stolenness integer,
    serial boolean DEFAULT false,
    includes_query boolean DEFAULT false,
    page integer,
    duration_ms integer,
    query_items jsonb,
    ip_address character varying,
    latitude double precision,
    longitude double precision,
    organization_id bigint,
    user_id bigint,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    serial_normalized character varying
);


--
-- Name: logged_searches_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.logged_searches_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: logged_searches_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.logged_searches_id_seq OWNED BY public.logged_searches.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);


--
-- Name: logged_searches id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.logged_searches ALTER COLUMN id SET DEFAULT nextval('public.logged_searches_id_seq'::regclass);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: logged_searches logged_searches_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.logged_searches
    ADD CONSTRAINT logged_searches_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: index_logged_searches_on_organization_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_logged_searches_on_organization_id ON public.logged_searches USING btree (organization_id);


--
-- Name: index_logged_searches_on_request_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_logged_searches_on_request_id ON public.logged_searches USING btree (request_id);


--
-- Name: index_logged_searches_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_logged_searches_on_user_id ON public.logged_searches USING btree (user_id);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO "schema_migrations" (version) VALUES
('20231025160704'),
('20231027162602');


