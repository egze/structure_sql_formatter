-- Name: measurement; Type: TABLE; Schema: public; Owner: postgres

CREATE TABLE public.measurement (
    city_id integer NOT NULL,
    logdate date NOT NULL,
    peaktemp integer,
    unitsales integer
)
PARTITION BY RANGE (logdate);

ALTER TABLE public.measurement OWNER TO postgres;
