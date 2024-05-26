-- Name: measurement; Type: TABLE; Schema: public; Owner: postgres

CREATE TABLE public.measurement (
   city_id integer NOT NULL,
   logdate date NOT NULL,
   peaktemp integer,
   unitsales integer
)
PARTITION BY RANGE (logdate);

ALTER TABLE public.measurement OWNER TO postgres;

ALTER TABLE public.measurement_y2006m02 OWNER TO postgres;

ALTER TABLE public.measurement_y2006m03 OWNER TO postgres;

-- Data for Name: measurement_y2006m02; Type: TABLE DATA; Schema: public; Owner: postgres

COPY public.measurement_y2006m02 (city_id, logdate, peaktemp, unitsales) FROM stdin;
\.

-- Data for Name: measurement_y2006m03; Type: TABLE DATA; Schema: public; Owner: postgres

COPY public.measurement_y2006m03 (city_id, logdate, peaktemp, unitsales) FROM stdin;
\.

-- PostgreSQL database dump complete
