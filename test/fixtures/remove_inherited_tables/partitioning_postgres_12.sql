--
-- Name: measurement; Type: TABLE; Schema: public; Owner: postgres
--

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
ALTER TABLE ONLY public.measurement ATTACH PARTITION public.measurement_y2006m02 FOR VALUES FROM ('2006-02-01') TO ('2006-03-01');
