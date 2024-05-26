-- Name: measurement; Type: TABLE; Schema: public; Owner: postgres

CREATE TABLE public.measurement (
    city_id integer NOT NULL,
    logdate date NOT NULL,
    peaktemp integer,
    unitsales integer
)
PARTITION BY RANGE (logdate);


ALTER TABLE public.measurement OWNER TO postgres;

SET default_table_access_method = heap;

--
-- Name: measurement_y2006m02; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.measurement_y2006m02 (
    city_id integer NOT NULL,
    logdate date NOT NULL,
    peaktemp integer,
    unitsales integer
);


ALTER TABLE public.measurement_y2006m02 OWNER TO postgres;

--
-- Name: measurement_y2006m03; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.measurement_y2006m03 (
    city_id integer NOT NULL,
    logdate date NOT NULL,
    peaktemp integer,
    unitsales integer
);


ALTER TABLE public.measurement_y2006m03 OWNER TO postgres;

--
-- Name: measurement_y2006m02; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.measurement ATTACH PARTITION public.measurement_y2006m02 FOR VALUES FROM ('2006-02-01') TO ('2006-03-01');


--
-- Name: measurement_y2006m03; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.measurement ATTACH PARTITION public.measurement_y2006m03 FOR VALUES FROM ('2006-03-01') TO ('2006-04-01');


--
-- Data for Name: measurement_y2006m02; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.measurement_y2006m02 (city_id, logdate, peaktemp, unitsales) FROM stdin;
\.


--
-- Data for Name: measurement_y2006m03; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.measurement_y2006m03 (city_id, logdate, peaktemp, unitsales) FROM stdin;
\.


--
-- Name: measurement_logdate_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX measurement_logdate_idx ON ONLY public.measurement USING btree (logdate);


--
-- Name: measurement_usls_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX measurement_usls_idx ON ONLY public.measurement USING btree (unitsales);


--
-- Name: measurement_usls_200602_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX measurement_usls_200602_idx ON public.measurement_y2006m02 USING btree (unitsales);


--
-- Name: measurement_y2006m02_logdate_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX measurement_y2006m02_logdate_idx ON public.measurement_y2006m02 USING btree (logdate);


--
-- Name: measurement_y2006m03_logdate_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX measurement_y2006m03_logdate_idx ON public.measurement_y2006m03 USING btree (logdate);


--
-- Name: measurement_usls_200602_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.measurement_usls_idx ATTACH PARTITION public.measurement_usls_200602_idx;


--
-- Name: measurement_y2006m02_logdate_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.measurement_logdate_idx ATTACH PARTITION public.measurement_y2006m02_logdate_idx;


--
-- Name: measurement_y2006m03_logdate_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.measurement_logdate_idx ATTACH PARTITION public.measurement_y2006m03_logdate_idx;


--
-- PostgreSQL database dump complete
--
