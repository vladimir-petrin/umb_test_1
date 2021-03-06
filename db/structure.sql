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

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- Name: update_avg_score_function(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.update_avg_score_function() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
        BEGIN
          IF    TG_OP = 'INSERT' THEN
            UPDATE posts
            SET avg_score = (SELECT AVG(value * 100) FROM scores WHERE scores.post_id = posts.id)
            WHERE id = NEW.post_id;

            RETURN NEW;
          ELSIF TG_OP = 'UPDATE' THEN
            IF NEW.post_id <> OLD.post_id OR NEW.value <> OLD.value THEN
              UPDATE posts
              SET avg_score = (SELECT AVG(value * 100) FROM scores WHERE scores.post_id = posts.id)
              WHERE id = NEW.post_id OR id = OLD.post_id;
            END IF;

            RETURN NEW;
          ELSIF TG_OP = 'DELETE' THEN
            UPDATE posts
            SET avg_score = (SELECT AVG(value * 100) FROM scores WHERE scores.post_id = posts.id)
            WHERE id = OLD.post_id;

            RETURN OLD;
          END IF;
        END
      $$;


SET default_tablespace = '';

SET default_with_oids = false;

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
-- Name: posts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.posts (
    id bigint NOT NULL,
    user_id integer NOT NULL,
    title character varying NOT NULL,
    content text NOT NULL,
    author_ip inet NOT NULL,
    avg_score smallint
);


--
-- Name: posts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.posts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: posts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.posts_id_seq OWNED BY public.posts.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);


--
-- Name: scores; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.scores (
    id bigint NOT NULL,
    post_id integer NOT NULL,
    value smallint NOT NULL
);


--
-- Name: scores_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.scores_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: scores_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.scores_id_seq OWNED BY public.scores.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id bigint NOT NULL,
    login character varying NOT NULL
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: posts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.posts ALTER COLUMN id SET DEFAULT nextval('public.posts_id_seq'::regclass);


--
-- Name: scores id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.scores ALTER COLUMN id SET DEFAULT nextval('public.scores_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: posts posts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.posts
    ADD CONSTRAINT posts_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: scores scores_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.scores
    ADD CONSTRAINT scores_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: index_posts_on_author_ip; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_posts_on_author_ip ON public.posts USING btree (author_ip);


--
-- Name: index_posts_on_avg_score; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_posts_on_avg_score ON public.posts USING btree (avg_score DESC NULLS LAST);


--
-- Name: index_posts_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_posts_on_user_id ON public.posts USING btree (user_id);


--
-- Name: index_scores_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_scores_on_post_id ON public.scores USING btree (post_id);


--
-- Name: index_users_on_login; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_login ON public.users USING btree (login);


--
-- Name: scores update_avg_score_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_avg_score_trigger AFTER INSERT OR DELETE OR UPDATE ON public.scores FOR EACH ROW EXECUTE PROCEDURE public.update_avg_score_function();


--
-- Name: posts fk_rails_5b5ddfd518; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.posts
    ADD CONSTRAINT fk_rails_5b5ddfd518 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: scores fk_rails_860fe32a5b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.scores
    ADD CONSTRAINT fk_rails_860fe32a5b FOREIGN KEY (post_id) REFERENCES public.posts(id);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO "schema_migrations" (version) VALUES
('20190821181935'),
('20190821182820'),
('20190821183000'),
('20190821194254');


