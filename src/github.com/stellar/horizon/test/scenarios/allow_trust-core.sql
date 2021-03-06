running recipe
recipe finished, closing ledger
ledger closed
--
-- PostgreSQL database dump
--

-- Dumped from database version 9.6.2
-- Dumped by pg_dump version 9.6.2

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

SET search_path = public, pg_catalog;

DROP INDEX IF EXISTS public.signersaccount;
DROP INDEX IF EXISTS public.sellingissuerindex;
DROP INDEX IF EXISTS public.scpquorumsbyseq;
DROP INDEX IF EXISTS public.scpenvsbyseq;
DROP INDEX IF EXISTS public.priceindex;
DROP INDEX IF EXISTS public.ledgersbyseq;
DROP INDEX IF EXISTS public.histfeebyseq;
DROP INDEX IF EXISTS public.histbyseq;
DROP INDEX IF EXISTS public.buyingissuerindex;
DROP INDEX IF EXISTS public.accountbalances;
ALTER TABLE IF EXISTS ONLY public.txhistory DROP CONSTRAINT IF EXISTS txhistory_pkey;
ALTER TABLE IF EXISTS ONLY public.txfeehistory DROP CONSTRAINT IF EXISTS txfeehistory_pkey;
ALTER TABLE IF EXISTS ONLY public.trustlines DROP CONSTRAINT IF EXISTS trustlines_pkey;
ALTER TABLE IF EXISTS ONLY public.storestate DROP CONSTRAINT IF EXISTS storestate_pkey;
ALTER TABLE IF EXISTS ONLY public.signers DROP CONSTRAINT IF EXISTS signers_pkey;
ALTER TABLE IF EXISTS ONLY public.scpquorums DROP CONSTRAINT IF EXISTS scpquorums_pkey;
ALTER TABLE IF EXISTS ONLY public.pubsub DROP CONSTRAINT IF EXISTS pubsub_pkey;
ALTER TABLE IF EXISTS ONLY public.publishqueue DROP CONSTRAINT IF EXISTS publishqueue_pkey;
ALTER TABLE IF EXISTS ONLY public.peers DROP CONSTRAINT IF EXISTS peers_pkey;
ALTER TABLE IF EXISTS ONLY public.offers DROP CONSTRAINT IF EXISTS offers_pkey;
ALTER TABLE IF EXISTS ONLY public.ledgerheaders DROP CONSTRAINT IF EXISTS ledgerheaders_pkey;
ALTER TABLE IF EXISTS ONLY public.ledgerheaders DROP CONSTRAINT IF EXISTS ledgerheaders_ledgerseq_key;
ALTER TABLE IF EXISTS ONLY public.ban DROP CONSTRAINT IF EXISTS ban_pkey;
ALTER TABLE IF EXISTS ONLY public.accounts DROP CONSTRAINT IF EXISTS accounts_pkey;
ALTER TABLE IF EXISTS ONLY public.accountdata DROP CONSTRAINT IF EXISTS accountdata_pkey;
DROP TABLE IF EXISTS public.txhistory;
DROP TABLE IF EXISTS public.txfeehistory;
DROP TABLE IF EXISTS public.trustlines;
DROP TABLE IF EXISTS public.storestate;
DROP TABLE IF EXISTS public.signers;
DROP TABLE IF EXISTS public.scpquorums;
DROP TABLE IF EXISTS public.scphistory;
DROP TABLE IF EXISTS public.pubsub;
DROP TABLE IF EXISTS public.publishqueue;
DROP TABLE IF EXISTS public.peers;
DROP TABLE IF EXISTS public.offers;
DROP TABLE IF EXISTS public.ledgerheaders;
DROP TABLE IF EXISTS public.ban;
DROP TABLE IF EXISTS public.accounts;
DROP TABLE IF EXISTS public.accountdata;
DROP EXTENSION IF EXISTS plpgsql;
DROP SCHEMA IF EXISTS public;
--
-- Name: public; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA public;


--
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON SCHEMA public IS 'standard public schema';


--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: accountdata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE accountdata (
    accountid character varying(56) NOT NULL,
    dataname character varying(64) NOT NULL,
    datavalue character varying(112) NOT NULL,
    lastmodified integer DEFAULT 0 NOT NULL
);


--
-- Name: accounts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE accounts (
    accountid character varying(56) NOT NULL,
    balance bigint NOT NULL,
    seqnum bigint NOT NULL,
    numsubentries integer NOT NULL,
    inflationdest character varying(56),
    homedomain character varying(32) NOT NULL,
    thresholds text NOT NULL,
    flags integer NOT NULL,
    lastmodified integer NOT NULL,
    CONSTRAINT accounts_balance_check CHECK ((balance >= 0)),
    CONSTRAINT accounts_numsubentries_check CHECK ((numsubentries >= 0))
);


--
-- Name: ban; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE ban (
    nodeid character(56) NOT NULL
);


--
-- Name: ledgerheaders; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE ledgerheaders (
    ledgerhash character(64) NOT NULL,
    prevhash character(64) NOT NULL,
    bucketlisthash character(64) NOT NULL,
    ledgerseq integer,
    closetime bigint NOT NULL,
    data text NOT NULL,
    CONSTRAINT ledgerheaders_closetime_check CHECK ((closetime >= 0)),
    CONSTRAINT ledgerheaders_ledgerseq_check CHECK ((ledgerseq >= 0))
);


--
-- Name: offers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE offers (
    sellerid character varying(56) NOT NULL,
    offerid bigint NOT NULL,
    sellingassettype integer NOT NULL,
    sellingassetcode character varying(12),
    sellingissuer character varying(56),
    buyingassettype integer NOT NULL,
    buyingassetcode character varying(12),
    buyingissuer character varying(56),
    amount bigint NOT NULL,
    pricen integer NOT NULL,
    priced integer NOT NULL,
    price double precision NOT NULL,
    flags integer NOT NULL,
    lastmodified integer NOT NULL,
    CONSTRAINT offers_amount_check CHECK ((amount >= 0)),
    CONSTRAINT offers_offerid_check CHECK ((offerid >= 0))
);


--
-- Name: peers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE peers (
    ip character varying(15) NOT NULL,
    port integer DEFAULT 0 NOT NULL,
    nextattempt timestamp without time zone NOT NULL,
    numfailures integer DEFAULT 0 NOT NULL,
    CONSTRAINT peers_numfailures_check CHECK ((numfailures >= 0)),
    CONSTRAINT peers_port_check CHECK (((port > 0) AND (port <= 65535)))
);


--
-- Name: publishqueue; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE publishqueue (
    ledger integer NOT NULL,
    state text
);


--
-- Name: pubsub; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE pubsub (
    resid character(32) NOT NULL,
    lastread integer
);


--
-- Name: scphistory; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE scphistory (
    nodeid character(56) NOT NULL,
    ledgerseq integer NOT NULL,
    envelope text NOT NULL,
    CONSTRAINT scphistory_ledgerseq_check CHECK ((ledgerseq >= 0))
);


--
-- Name: scpquorums; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE scpquorums (
    qsethash character(64) NOT NULL,
    lastledgerseq integer NOT NULL,
    qset text NOT NULL,
    CONSTRAINT scpquorums_lastledgerseq_check CHECK ((lastledgerseq >= 0))
);


--
-- Name: signers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE signers (
    accountid character varying(56) NOT NULL,
    publickey character varying(56) NOT NULL,
    weight integer NOT NULL
);


--
-- Name: storestate; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE storestate (
    statename character(32) NOT NULL,
    state text
);


--
-- Name: trustlines; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE trustlines (
    accountid character varying(56) NOT NULL,
    assettype integer NOT NULL,
    issuer character varying(56) NOT NULL,
    assetcode character varying(12) NOT NULL,
    tlimit bigint NOT NULL,
    balance bigint NOT NULL,
    flags integer NOT NULL,
    lastmodified integer NOT NULL,
    CONSTRAINT trustlines_balance_check CHECK ((balance >= 0)),
    CONSTRAINT trustlines_tlimit_check CHECK ((tlimit > 0))
);


--
-- Name: txfeehistory; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE txfeehistory (
    txid character(64) NOT NULL,
    ledgerseq integer NOT NULL,
    txindex integer NOT NULL,
    txchanges text NOT NULL,
    CONSTRAINT txfeehistory_ledgerseq_check CHECK ((ledgerseq >= 0))
);


--
-- Name: txhistory; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE txhistory (
    txid character(64) NOT NULL,
    ledgerseq integer NOT NULL,
    txindex integer NOT NULL,
    txbody text NOT NULL,
    txresult text NOT NULL,
    txmeta text NOT NULL,
    CONSTRAINT txhistory_ledgerseq_check CHECK ((ledgerseq >= 0))
);


--
-- Data for Name: accountdata; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: accounts; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO accounts VALUES ('GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H', 999999969999999700, 3, 0, NULL, '', 'AQAAAA==', 0, 2);
INSERT INTO accounts VALUES ('GCXKG6RN4ONIEPCMNFB732A436Z5PNDSRLGWK7GBLCMQLIFO4S7EYWVU', 9999999900, 8589934593, 1, NULL, '', 'AQAAAA==', 0, 4);
INSERT INTO accounts VALUES ('GBXGQJWVLWOYHFLVTKWV5FGHA3LNYY2JQKM7OAJAUEQFU6LPCSEFVXON', 9999999900, 8589934593, 1, NULL, '', 'AQAAAA==', 0, 5);
INSERT INTO accounts VALUES ('GC23QF2HUE52AMXUFUH3AYJAXXGXXV2VHXYYR6EYXETPKDXZSAW67XO4', 9999999500, 8589934597, 0, NULL, '', 'AQAAAA==', 3, 8);


--
-- Data for Name: ban; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: ledgerheaders; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO ledgerheaders VALUES ('63d98f536ee68d1b27b5b89f23af5311b7569a24faf1403ad0b52b633b07be99', '0000000000000000000000000000000000000000000000000000000000000000', '572a2e32ff248a07b0e70fd1f6d318c1facd20b6cc08c33d5775259868125a16', 1, 0, 'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABXKi4y/ySKB7DnD9H20xjB+s0gtswIwz1XdSWYaBJaFgAAAAEN4Lazp2QAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAZAX14QAAAABkAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA');
INSERT INTO ledgerheaders VALUES ('fb624c40d5c62f3204cd8a069248bf13af316ca7f5020b9fad443dd885e52c9f', '63d98f536ee68d1b27b5b89f23af5311b7569a24faf1403ad0b52b633b07be99', '01b733cfde9f97fb8d590e1baf6ea77d8013e13006b4e13f8519346d93dc87b4', 2, 1499888209, 'AAAABGPZj1Nu5o0bJ7W4nyOvUxG3Vpok+vFAOtC1K2M7B76ZU7nPOoI7SirHEO1Sa67WumwKQ62PpQGlvJvyyQ8QGEYAAAAAWWZ6UQAAAAIAAAAIAAAAAQAAAAQAAAAIAAAAAwAAJxAAAAAAj6+p+aI7JvbSfHisaUUAXhzcG+/2YWJE2bnf4zuV8i4BtzPP3p+X+41ZDhuvbqd9gBPhMAa04T+FGTRtk9yHtAAAAAIN4Lazp2QAAAAAAAAAAAEsAAAAAAAAAAAAAAAAAAAAZAX14QAAACcQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA');
INSERT INTO ledgerheaders VALUES ('c15cd03dd651069f01c3b6a26e9f6dc51f844203ce295a545a41a955bd4eb8d9', 'fb624c40d5c62f3204cd8a069248bf13af316ca7f5020b9fad443dd885e52c9f', '39884abf2a5c1b93f305bbde369e6648cedf9c7e941046f5af2ba84b8152779f', 3, 1499888210, 'AAAABPtiTEDVxi8yBM2KBpJIvxOvMWyn9QILn61EPdiF5Syf1ey7784JcBm2FjJlB4E4j4jsBK8W+2XvJgW990Fv4HEAAAAAWWZ6UgAAAAAAAAAATlvjBWe7MinR9n7UosajCKxUpgQMBBbhmF6bHAvPHGU5iEq/Klwbk/MFu942nmZIzt+cfpQQRvWvK6hLgVJ3nwAAAAMN4Lazp2QAAAAAAAAAAAH0AAAAAAAAAAAAAAAAAAAAZAX14QAAACcQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA');
INSERT INTO ledgerheaders VALUES ('b9d774d446e11582caaa25ea2dbb2f3f4bfa6e86d93beceb58169de612e4bb76', 'c15cd03dd651069f01c3b6a26e9f6dc51f844203ce295a545a41a955bd4eb8d9', '00ce11e04988fb9a1fadb6c999179272245d00148f1f7bfbee5af6e1f55b5155', 4, 1499888211, 'AAAABMFc0D3WUQafAcO2om6fbcUfhEIDzilaVFpBqVW9TrjZkMHMzKiZxS4TfzDnZE9OT/UpLG27Z8FKZscHc43l+5wAAAAAWWZ6UwAAAAAAAAAALLKPbMojH+RR+TSBDKGB/tufH2mL12ccCHr1Jn27yPAAzhHgSYj7mh+ttsmZF5JyJF0AFI8fe/vuWvbh9VtRVQAAAAQN4Lazp2QAAAAAAAAAAAJYAAAAAAAAAAAAAAAAAAAAZAX14QAAACcQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA');
INSERT INTO ledgerheaders VALUES ('1b774c3419d950479953041d1301a7f791f4ba0fd7d9b8045f756b42be201dc4', 'b9d774d446e11582caaa25ea2dbb2f3f4bfa6e86d93beceb58169de612e4bb76', '9c00f2d58fdd33ebdd9a14c33fb09066476ac4ca6591d0520777f798ac32dd75', 5, 1499888212, 'AAAABLnXdNRG4RWCyqol6i27Lz9L+m6G2Tvs61gWneYS5Lt2jDM8W7f2iDtutyG0VK0xGGBfu16hDBNMk6adVGSgwooAAAAAWWZ6VAAAAAAAAAAAxlJuyWie0d1LzUCR1K4LD2g+0KuAHvbJ+SgmGHyguLWcAPLVj90z692aFMM/sJBmR2rEymWR0FIHd/eYrDLddQAAAAUN4Lazp2QAAAAAAAAAAAK8AAAAAAAAAAAAAAAAAAAAZAX14QAAACcQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA');
INSERT INTO ledgerheaders VALUES ('630c5d7086435cbf73b7303c1910c03616406825b9a5ff1be46a250313975e2f', '1b774c3419d950479953041d1301a7f791f4ba0fd7d9b8045f756b42be201dc4', 'e8c8563156d6d2d1ca35a3b3eb520fc34fd1eca0dd822e72b3bdf7880e02181f', 6, 1499888213, 'AAAABBt3TDQZ2VBHmVMEHRMBp/eR9LoP19m4BF91a0K+IB3EfTLBxO1BDvfC/fAdQiBycQPmrlTMUZO5RX53/yQMUGsAAAAAWWZ6VQAAAAAAAAAAFp2fvkMO7OW+Jq1zFYvyIp0pN6KM6DetMmxOjZVOCKfoyFYxVtbS0co1o7PrUg/DT9HsoN2CLnKzvfeIDgIYHwAAAAYN4Lazp2QAAAAAAAAAAAMgAAAAAAAAAAAAAAAAAAAAZAX14QAAACcQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA');
INSERT INTO ledgerheaders VALUES ('23156ddd9deafca83ba45b563e678416f79208b3c0d273ea55ade9ed7f69e0e6', '630c5d7086435cbf73b7303c1910c03616406825b9a5ff1be46a250313975e2f', '98f53fc9f25f194602769ef1cf82c3812d7894b7ff34a1b088b8d610fb993e1d', 7, 1499888214, 'AAAABGMMXXCGQ1y/c7cwPBkQwDYWQGgluaX/G+RqJQMTl14vUDVynNJOR+B7iXJ5M8ZTgIU3kFpDdMcw/6eO9AH9wAkAAAAAWWZ6VgAAAAAAAAAA2F0xW7K6lNYrXRzu7d5HyBUnPlumNFQipNBwSQNAx1KY9T/J8l8ZRgJ2nvHPgsOBLXiUt/80obCIuNYQ+5k+HQAAAAcN4Lazp2QAAAAAAAAAAAOEAAAAAAAAAAAAAAAAAAAAZAX14QAAACcQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA');
INSERT INTO ledgerheaders VALUES ('82fd6aa1fc611554b9777bcbe3cff1454446b118d92a4c2c432f6ffbce43e9c9', '23156ddd9deafca83ba45b563e678416f79208b3c0d273ea55ade9ed7f69e0e6', 'c9d1407eb6f6d1bcbfe6af0babe9300b8169ab0cbfbe15fa6fa1121e63369049', 8, 1499888215, 'AAAABCMVbd2d6vyoO6RbVj5nhBb3kgizwNJz6lWt6e1/aeDmPwb+Ul6eU+wCkScvyUBUocFhb7LIorXONMveF2BioI0AAAAAWWZ6VwAAAAAAAAAA17tytOKBxgu8yeo5X/akyYnyYlyrUb7gJWE+zfCgC2DJ0UB+tvbRvL/mrwur6TALgWmrDL++FfpvoRIeYzaQSQAAAAgN4Lazp2QAAAAAAAAAAAPoAAAAAAAAAAAAAAAAAAAAZAX14QAAACcQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA');
INSERT INTO ledgerheaders VALUES ('a63578ccbfa2e6c3a97bef888867e72c38f2cddc15235786b80c1b53a4b0d07e', '82fd6aa1fc611554b9777bcbe3cff1454446b118d92a4c2c432f6ffbce43e9c9', 'c9d1407eb6f6d1bcbfe6af0babe9300b8169ab0cbfbe15fa6fa1121e63369049', 9, 1499888216, 'AAAABIL9aqH8YRVUuXd7y+PP8UVERrEY2SpMLEMvb/vOQ+nJfVmA7dbzRqDSbl7npWlslRUfMaqA4h0e9TC2M/abtgYAAAAAWWZ6WAAAAAAAAAAA3z9hmASpL9tAVxktxD3XSOp3itxSvEmM6AUkwBS4ERnJ0UB+tvbRvL/mrwur6TALgWmrDL++FfpvoRIeYzaQSQAAAAkN4Lazp2QAAAAAAAAAAAPoAAAAAAAAAAAAAAAAAAAAZAX14QAAACcQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA');


--
-- Data for Name: offers; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: peers; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: publishqueue; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: pubsub; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: scphistory; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO scphistory VALUES ('GDUGGMDGSDKOQSIWWGX2AOGO6LTJWJ2BO2WASDT2ADVWUGDI5GXMSRCD', 2, 'AAAAAOhjMGaQ1OhJFrGvoDjO8uabJ0F2rAkOegDrahho6a7JAAAAAAAAAAIAAAACAAAAAQAAAEhTuc86gjtKKscQ7VJrrta6bApDrY+lAaW8m/LJDxAYRgAAAABZZnpRAAAAAgAAAAgAAAABAAAABAAAAAgAAAADAAAnEAAAAAAAAAABbhxm/kgbpg5D2d9BD0XBruB3m7BCgI5T1GBdSRsHqwIAAABATU4ZFsA76Ah5svocUxasnDbQX5++gH+kU0c17KEYK5//obi8HenOA0avEvKNJQtW5Hm09UQdcazYLYWOMDosCA==');
INSERT INTO scphistory VALUES ('GDUGGMDGSDKOQSIWWGX2AOGO6LTJWJ2BO2WASDT2ADVWUGDI5GXMSRCD', 3, 'AAAAAOhjMGaQ1OhJFrGvoDjO8uabJ0F2rAkOegDrahho6a7JAAAAAAAAAAMAAAACAAAAAQAAADDV7LvvzglwGbYWMmUHgTiPiOwErxb7Ze8mBb33QW/gcQAAAABZZnpSAAAAAAAAAAAAAAABbhxm/kgbpg5D2d9BD0XBruB3m7BCgI5T1GBdSRsHqwIAAABAsGQux6xdSLz9IGrI3IESXxIK1zW7HMuDZahCqz3GpMTrTE/QYNpZmjdD0CPD7zkiD1sB1ij25vnJp122gPZZDg==');
INSERT INTO scphistory VALUES ('GDUGGMDGSDKOQSIWWGX2AOGO6LTJWJ2BO2WASDT2ADVWUGDI5GXMSRCD', 4, 'AAAAAOhjMGaQ1OhJFrGvoDjO8uabJ0F2rAkOegDrahho6a7JAAAAAAAAAAQAAAACAAAAAQAAADCQwczMqJnFLhN/MOdkT05P9SksbbtnwUpmxwdzjeX7nAAAAABZZnpTAAAAAAAAAAAAAAABbhxm/kgbpg5D2d9BD0XBruB3m7BCgI5T1GBdSRsHqwIAAABA+yak4jc/jm+j1ZJyZojm46iSTP/zCIN9gdCG8pVTuESNN4RyBtjMI59tW1Tn/UfJPtg8ozW4nBMOVleaD2FgDg==');
INSERT INTO scphistory VALUES ('GDUGGMDGSDKOQSIWWGX2AOGO6LTJWJ2BO2WASDT2ADVWUGDI5GXMSRCD', 5, 'AAAAAOhjMGaQ1OhJFrGvoDjO8uabJ0F2rAkOegDrahho6a7JAAAAAAAAAAUAAAACAAAAAQAAADCMMzxbt/aIO263IbRUrTEYYF+7XqEME0yTpp1UZKDCigAAAABZZnpUAAAAAAAAAAAAAAABbhxm/kgbpg5D2d9BD0XBruB3m7BCgI5T1GBdSRsHqwIAAABAeWvQsNGxEd/1nSouDBAZa4h6HGfAGZN0fQ0dHpOXqiBbxZtvaw+Qkkr4W/9uKMPnCPB3t2rdqGw/Ij1FKJT0Cg==');
INSERT INTO scphistory VALUES ('GDUGGMDGSDKOQSIWWGX2AOGO6LTJWJ2BO2WASDT2ADVWUGDI5GXMSRCD', 6, 'AAAAAOhjMGaQ1OhJFrGvoDjO8uabJ0F2rAkOegDrahho6a7JAAAAAAAAAAYAAAACAAAAAQAAADB9MsHE7UEO98L98B1CIHJxA+auVMxRk7lFfnf/JAxQawAAAABZZnpVAAAAAAAAAAAAAAABbhxm/kgbpg5D2d9BD0XBruB3m7BCgI5T1GBdSRsHqwIAAABAyijOfFgQbAgSGHwLzEsFIEGCKIGJSCGj8YSyDM9uToGjzch5Czkr+o+MEoR4bJCCBFvv8gs8oxk6sGbltWtWAw==');
INSERT INTO scphistory VALUES ('GDUGGMDGSDKOQSIWWGX2AOGO6LTJWJ2BO2WASDT2ADVWUGDI5GXMSRCD', 7, 'AAAAAOhjMGaQ1OhJFrGvoDjO8uabJ0F2rAkOegDrahho6a7JAAAAAAAAAAcAAAACAAAAAQAAADBQNXKc0k5H4HuJcnkzxlOAhTeQWkN0xzD/p470Af3ACQAAAABZZnpWAAAAAAAAAAAAAAABbhxm/kgbpg5D2d9BD0XBruB3m7BCgI5T1GBdSRsHqwIAAABAi+XBy07Kak2tNuQeX6Gaogz2FP5W4cn9lJpOT6nXrovGMT7ROQjfp2ybzTYXqTAQctPcUNOAgHEPQhQVKe6bCw==');
INSERT INTO scphistory VALUES ('GDUGGMDGSDKOQSIWWGX2AOGO6LTJWJ2BO2WASDT2ADVWUGDI5GXMSRCD', 8, 'AAAAAOhjMGaQ1OhJFrGvoDjO8uabJ0F2rAkOegDrahho6a7JAAAAAAAAAAgAAAACAAAAAQAAADA/Bv5SXp5T7AKRJy/JQFShwWFvssiitc40y94XYGKgjQAAAABZZnpXAAAAAAAAAAAAAAABbhxm/kgbpg5D2d9BD0XBruB3m7BCgI5T1GBdSRsHqwIAAABAwhmvKzYkQcXE9Ckbj/RWeNy6s4AFZgIoHqXbxxU2aOJlweKoSOrt642rAeDaa7z8eDOqfh5kCxfYz8aelzXnCQ==');
INSERT INTO scphistory VALUES ('GDUGGMDGSDKOQSIWWGX2AOGO6LTJWJ2BO2WASDT2ADVWUGDI5GXMSRCD', 9, 'AAAAAOhjMGaQ1OhJFrGvoDjO8uabJ0F2rAkOegDrahho6a7JAAAAAAAAAAkAAAACAAAAAQAAADB9WYDt1vNGoNJuXuelaWyVFR8xqoDiHR71MLYz9pu2BgAAAABZZnpYAAAAAAAAAAAAAAABbhxm/kgbpg5D2d9BD0XBruB3m7BCgI5T1GBdSRsHqwIAAABAYz4VRoCJOdeYOouVxhDJ0kZULZEZoTiVBDmVUG3g75llh/La0yJl8RGynRi/6kR9I1dMa8RmCxV0JQzggrUwAg==');


--
-- Data for Name: scpquorums; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO scpquorums VALUES ('6e1c66fe481ba60e43d9df410f45c1aee0779bb042808e53d4605d491b07ab02', 9, 'AAAAAQAAAAEAAAAA6GMwZpDU6EkWsa+gOM7y5psnQXasCQ56AOtqGGjprskAAAAA');


--
-- Data for Name: signers; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: storestate; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO storestate VALUES ('lastclosedledger                ', 'a63578ccbfa2e6c3a97bef888867e72c38f2cddc15235786b80c1b53a4b0d07e');
INSERT INTO storestate VALUES ('historyarchivestate             ', '{
    "version": 1,
    "server": "v0.6.1-2-g12a1603e-dirty",
    "currentLedger": 9,
    "currentBuckets": [
        {
            "curr": "7143480fc84788c095e494cd2844321a62ce81d2e1d3ba6c15b9ac5d6bfe5848",
            "next": {
                "state": 0
            },
            "snap": "5fbe1e53bf079fb1745944c3b0eb066c16f2934238ae0c1595fdf6bdabf709c8"
        },
        {
            "curr": "119e94eda9f771a7917b37dc2a53fcdd55de1fd33f3ffebff65ee207b4947213",
            "next": {
                "state": 1,
                "output": "3a47c2d0cba5d3c8e84a8c739cab7a661dd1d13898ad9c4ae6281dc996c574c0"
            },
            "snap": "5d0267c5830128805375bd61c17d3b41edc594f0c0d0c520b0f57776624eaa50"
        },
        {
            "curr": "0000000000000000000000000000000000000000000000000000000000000000",
            "next": {
                "state": 1,
                "output": "85d70ff8507c4a08f80fed6c67c989ce8b4515db24cd1c1e5bd36dccbc8c43e2"
            },
            "snap": "0000000000000000000000000000000000000000000000000000000000000000"
        },
        {
            "curr": "0000000000000000000000000000000000000000000000000000000000000000",
            "next": {
                "state": 0
            },
            "snap": "0000000000000000000000000000000000000000000000000000000000000000"
        },
        {
            "curr": "0000000000000000000000000000000000000000000000000000000000000000",
            "next": {
                "state": 0
            },
            "snap": "0000000000000000000000000000000000000000000000000000000000000000"
        },
        {
            "curr": "0000000000000000000000000000000000000000000000000000000000000000",
            "next": {
                "state": 0
            },
            "snap": "0000000000000000000000000000000000000000000000000000000000000000"
        },
        {
            "curr": "0000000000000000000000000000000000000000000000000000000000000000",
            "next": {
                "state": 0
            },
            "snap": "0000000000000000000000000000000000000000000000000000000000000000"
        },
        {
            "curr": "0000000000000000000000000000000000000000000000000000000000000000",
            "next": {
                "state": 0
            },
            "snap": "0000000000000000000000000000000000000000000000000000000000000000"
        },
        {
            "curr": "0000000000000000000000000000000000000000000000000000000000000000",
            "next": {
                "state": 0
            },
            "snap": "0000000000000000000000000000000000000000000000000000000000000000"
        },
        {
            "curr": "0000000000000000000000000000000000000000000000000000000000000000",
            "next": {
                "state": 0
            },
            "snap": "0000000000000000000000000000000000000000000000000000000000000000"
        },
        {
            "curr": "0000000000000000000000000000000000000000000000000000000000000000",
            "next": {
                "state": 0
            },
            "snap": "0000000000000000000000000000000000000000000000000000000000000000"
        }
    ]
}');
INSERT INTO storestate VALUES ('databaseschema                  ', '5');
INSERT INTO storestate VALUES ('forcescponnextlaunch            ', 'false');
INSERT INTO storestate VALUES ('lastscpdata                     ', 'AAAAAgAAAADoYzBmkNToSRaxr6A4zvLmmydBdqwJDnoA62oYaOmuyQAAAAAAAAAJAAAAA24cZv5IG6YOQ9nfQQ9Fwa7gd5uwQoCOU9RgXUkbB6sCAAAAAQAAADB9WYDt1vNGoNJuXuelaWyVFR8xqoDiHR71MLYz9pu2BgAAAABZZnpYAAAAAAAAAAAAAAABAAAAMH1ZgO3W80ag0m5e56VpbJUVHzGqgOIdHvUwtjP2m7YGAAAAAFlmelgAAAAAAAAAAAAAAEAtr8S+LSYzToRCBeQ+AR8tjvhvDwW0Yzb4fTONtAdpJXz878kB1hKfdpRHQVz3Quyzcd1ucrHdv2zBEIlNu38BAAAAAOhjMGaQ1OhJFrGvoDjO8uabJ0F2rAkOegDrahho6a7JAAAAAAAAAAkAAAACAAAAAQAAADB9WYDt1vNGoNJuXuelaWyVFR8xqoDiHR71MLYz9pu2BgAAAABZZnpYAAAAAAAAAAAAAAABbhxm/kgbpg5D2d9BD0XBruB3m7BCgI5T1GBdSRsHqwIAAABAYz4VRoCJOdeYOouVxhDJ0kZULZEZoTiVBDmVUG3g75llh/La0yJl8RGynRi/6kR9I1dMa8RmCxV0JQzggrUwAgAAAAGC/Wqh/GEVVLl3e8vjz/FFREaxGNkqTCxDL2/7zkPpyQAAAAAAAAABAAAAAQAAAAEAAAAA6GMwZpDU6EkWsa+gOM7y5psnQXasCQ56AOtqGGjprskAAAAA');


--
-- Data for Name: trustlines; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO trustlines VALUES ('GCXKG6RN4ONIEPCMNFB732A436Z5PNDSRLGWK7GBLCMQLIFO4S7EYWVU', 1, 'GC23QF2HUE52AMXUFUH3AYJAXXGXXV2VHXYYR6EYXETPKDXZSAW67XO4', 'USD', 9223372036854775807, 0, 1, 6);
INSERT INTO trustlines VALUES ('GBXGQJWVLWOYHFLVTKWV5FGHA3LNYY2JQKM7OAJAUEQFU6LPCSEFVXON', 1, 'GC23QF2HUE52AMXUFUH3AYJAXXGXXV2VHXYYR6EYXETPKDXZSAW67XO4', 'USD', 40000000000, 0, 0, 8);


--
-- Data for Name: txfeehistory; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO txfeehistory VALUES ('db398eb4ae89756325643cad21c94e13bfc074b323ee83e141bf701a5d904f1b', 2, 1, 'AAAAAgAAAAMAAAABAAAAAAAAAABi/B0L0JGythwN1lY0aypo19NHxvLCyO5tBEcCVvwF9w3gtrOnZAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAEAAAACAAAAAAAAAABi/B0L0JGythwN1lY0aypo19NHxvLCyO5tBEcCVvwF9w3gtrOnY/+cAAAAAAAAAAEAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==');
INSERT INTO txfeehistory VALUES ('f97caffab8c16023a37884165cb0b3ff1aa2daf4000fef49d21efc847ddbfbea', 2, 2, 'AAAAAQAAAAEAAAACAAAAAAAAAABi/B0L0JGythwN1lY0aypo19NHxvLCyO5tBEcCVvwF9w3gtrOnY/84AAAAAAAAAAIAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==');
INSERT INTO txfeehistory VALUES ('90880ac53815dac8441add0220a7631ef5eac3d57c2e89634ea9b5203f61a8e4', 2, 3, 'AAAAAQAAAAEAAAACAAAAAAAAAABi/B0L0JGythwN1lY0aypo19NHxvLCyO5tBEcCVvwF9w3gtrOnY/7UAAAAAAAAAAMAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==');
INSERT INTO txfeehistory VALUES ('7a707186a5cc36a0e520548ae511b53896c0391ce166d40da80588cbaae6aa2c', 3, 1, 'AAAAAgAAAAMAAAACAAAAAAAAAAC1uBdHoTugMvQtD7BhIL3Ne9dVPfGI+Ji5JvUO+ZAt7wAAAAJUC+QAAAAAAgAAAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAEAAAADAAAAAAAAAAC1uBdHoTugMvQtD7BhIL3Ne9dVPfGI+Ji5JvUO+ZAt7wAAAAJUC+OcAAAAAgAAAAEAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==');
INSERT INTO txfeehistory VALUES ('c6bfdd93f1470df9dfa3ef95d57ba28cecace068d9f2bb040a79ffc7c5d96cb9', 3, 2, 'AAAAAQAAAAEAAAADAAAAAAAAAAC1uBdHoTugMvQtD7BhIL3Ne9dVPfGI+Ji5JvUO+ZAt7wAAAAJUC+M4AAAAAgAAAAIAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==');
INSERT INTO txfeehistory VALUES ('bd486dbdd02d460817671c4a5a7e9d6e865ca29cb41e62d7aaf70a2fee5b36de', 4, 1, 'AAAAAgAAAAMAAAACAAAAAAAAAACuo3ot45qCPExpQ/3oHN+z17Ryis1lfMFYmQWgruS+TAAAAAJUC+QAAAAAAgAAAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAEAAAAEAAAAAAAAAACuo3ot45qCPExpQ/3oHN+z17Ryis1lfMFYmQWgruS+TAAAAAJUC+OcAAAAAgAAAAEAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==');
INSERT INTO txfeehistory VALUES ('b55d768a4e8e712da20efdee0e7d85f02948f9b6fd3ef2daefd3a5a147ecd63d', 5, 1, 'AAAAAgAAAAMAAAACAAAAAAAAAABuaCbVXZ2DlXWarV6UxwbW3GNJgpn3ASChIFp5bxSIWgAAAAJUC+QAAAAAAgAAAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAEAAAAFAAAAAAAAAABuaCbVXZ2DlXWarV6UxwbW3GNJgpn3ASChIFp5bxSIWgAAAAJUC+OcAAAAAgAAAAEAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==');
INSERT INTO txfeehistory VALUES ('3b666a253313fc7a0d241ee28064eec78aaa5ebd0a7c0ae7f85259e80fad029f', 6, 1, 'AAAAAgAAAAMAAAADAAAAAAAAAAC1uBdHoTugMvQtD7BhIL3Ne9dVPfGI+Ji5JvUO+ZAt7wAAAAJUC+M4AAAAAgAAAAIAAAAAAAAAAAAAAAMAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAEAAAAGAAAAAAAAAAC1uBdHoTugMvQtD7BhIL3Ne9dVPfGI+Ji5JvUO+ZAt7wAAAAJUC+LUAAAAAgAAAAMAAAAAAAAAAAAAAAMAAAAAAQAAAAAAAAAAAAAAAAAAAA==');
INSERT INTO txfeehistory VALUES ('3f2aa00ba539e24ba9c0ba62f50318d8c7180f2d6757cc76e9984055c5e19ff4', 7, 1, 'AAAAAgAAAAMAAAAGAAAAAAAAAAC1uBdHoTugMvQtD7BhIL3Ne9dVPfGI+Ji5JvUO+ZAt7wAAAAJUC+LUAAAAAgAAAAMAAAAAAAAAAAAAAAMAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAEAAAAHAAAAAAAAAAC1uBdHoTugMvQtD7BhIL3Ne9dVPfGI+Ji5JvUO+ZAt7wAAAAJUC+JwAAAAAgAAAAQAAAAAAAAAAAAAAAMAAAAAAQAAAAAAAAAAAAAAAAAAAA==');
INSERT INTO txfeehistory VALUES ('3ce9fc1159c25adc62c9686792cd41f06908280b899744057856db33bafe75de', 8, 1, 'AAAAAgAAAAMAAAAHAAAAAAAAAAC1uBdHoTugMvQtD7BhIL3Ne9dVPfGI+Ji5JvUO+ZAt7wAAAAJUC+JwAAAAAgAAAAQAAAAAAAAAAAAAAAMAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAEAAAAIAAAAAAAAAAC1uBdHoTugMvQtD7BhIL3Ne9dVPfGI+Ji5JvUO+ZAt7wAAAAJUC+IMAAAAAgAAAAUAAAAAAAAAAAAAAAMAAAAAAQAAAAAAAAAAAAAAAAAAAA==');


--
-- Data for Name: txhistory; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO txhistory VALUES ('db398eb4ae89756325643cad21c94e13bfc074b323ee83e141bf701a5d904f1b', 2, 1, 'AAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3AAAAZAAAAAAAAAABAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAtbgXR6E7oDL0LQ+wYSC9zXvXVT3xiPiYuSb1DvmQLe8AAAACVAvkAAAAAAAAAAABVvwF9wAAAEAYjQcPT2G5hqnBmgGGeg9J8l4c1EnUlxklElH9sqZr0971F6OLWfe/m4kpFtI+sI0i1qLit5A0JyWnbhYLW5oD', '2zmOtK6JdWMlZDytIclOE7/AdLMj7oPhQb9wGl2QTxsAAAAAAAAAZAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAA==', 'AAAAAAAAAAEAAAACAAAAAAAAAAIAAAAAAAAAALW4F0ehO6Ay9C0PsGEgvc1711U98Yj4mLkm9Q75kC3vAAAAAlQL5AAAAAACAAAAAAAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAIAAAAAAAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3DeC2sVNYGtQAAAAAAAAAAwAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAA');
INSERT INTO txhistory VALUES ('f97caffab8c16023a37884165cb0b3ff1aa2daf4000fef49d21efc847ddbfbea', 2, 2, 'AAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3AAAAZAAAAAAAAAACAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAArqN6LeOagjxMaUP96Bzfs9e0corNZXzBWJkFoK7kvkwAAAACVAvkAAAAAAAAAAABVvwF9wAAAEBmKpSgvrwKO20XCOfYfXsGEEUtwYaaEfqSu6ymJmlDma+IX6I7IggbUZMocQdZ94IMAfKdQANqXbIO7ysweeMC', '+Xyv+rjBYCOjeIQWXLCz/xqi2vQAD+9J0h78hH3b++oAAAAAAAAAZAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAA==', 'AAAAAAAAAAEAAAACAAAAAAAAAAIAAAAAAAAAAK6jei3jmoI8TGlD/egc37PXtHKKzWV8wViZBaCu5L5MAAAAAlQL5AAAAAACAAAAAAAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAIAAAAAAAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3DeC2rv9MNtQAAAAAAAAAAwAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAA');
INSERT INTO txhistory VALUES ('90880ac53815dac8441add0220a7631ef5eac3d57c2e89634ea9b5203f61a8e4', 2, 3, 'AAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3AAAAZAAAAAAAAAADAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAbmgm1V2dg5V1mq1elMcG1txjSYKZ9wEgoSBaeW8UiFoAAAACVAvkAAAAAAAAAAABVvwF9wAAAEBdX4R/Ghzq8/r+u8PL+sNriHsS5lW1Vt+9eCe0nnWMNTzMgcUbarePbrpD2gr8DjVumcmpVH9wG2GXtWvwzXoL', 'kIgKxTgV2shEGt0CIKdjHvXqw9V8LoljTqm1ID9hqOQAAAAAAAAAZAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAA==', 'AAAAAAAAAAEAAAACAAAAAAAAAAIAAAAAAAAAAG5oJtVdnYOVdZqtXpTHBtbcY0mCmfcBIKEgWnlvFIhaAAAAAlQL5AAAAAACAAAAAAAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAIAAAAAAAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3DeC2rKtAUtQAAAAAAAAAAwAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAA');
INSERT INTO txhistory VALUES ('7a707186a5cc36a0e520548ae511b53896c0391ce166d40da80588cbaae6aa2c', 3, 1, 'AAAAALW4F0ehO6Ay9C0PsGEgvc1711U98Yj4mLkm9Q75kC3vAAAAZAAAAAIAAAABAAAAAAAAAAAAAAABAAAAAAAAAAUAAAAAAAAAAQAAAAAAAAABAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAB+ZAt7wAAAEDBhDOsFWP2KCoZuJDRXuiNm0CjgVKLLtdZi/A3OfrCsgvX8izhAllXkRqrXyitSvGo3kQh6V/S/tnQbrYgHQQG', 'enBxhqXMNqDlIFSK5RG1OJbAORzhZtQNqAWIy6rmqiwAAAAAAAAAZAAAAAAAAAABAAAAAAAAAAUAAAAAAAAAAA==', 'AAAAAAAAAAEAAAABAAAAAQAAAAMAAAAAAAAAALW4F0ehO6Ay9C0PsGEgvc1711U98Yj4mLkm9Q75kC3vAAAAAlQL4zgAAAACAAAAAgAAAAAAAAAAAAAAAQAAAAABAAAAAAAAAAAAAAAAAAAA');
INSERT INTO txhistory VALUES ('c6bfdd93f1470df9dfa3ef95d57ba28cecace068d9f2bb040a79ffc7c5d96cb9', 3, 2, 'AAAAALW4F0ehO6Ay9C0PsGEgvc1711U98Yj4mLkm9Q75kC3vAAAAZAAAAAIAAAACAAAAAAAAAAAAAAABAAAAAAAAAAUAAAAAAAAAAQAAAAAAAAABAAAAAgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAB+ZAt7wAAAEBVJkTQTFlpFKoMhcibMpdJ5khR91LY3zPQwv/e5Ov7XIcWKGIv5sDfgyhaK/x5WYWfawNWcc5fMlW7c/PxGOQJ', 'xr/dk/FHDfnfo++V1XuijOys4GjZ8rsECnn/x8XZbLkAAAAAAAAAZAAAAAAAAAABAAAAAAAAAAUAAAAAAAAAAA==', 'AAAAAAAAAAEAAAABAAAAAQAAAAMAAAAAAAAAALW4F0ehO6Ay9C0PsGEgvc1711U98Yj4mLkm9Q75kC3vAAAAAlQL4zgAAAACAAAAAgAAAAAAAAAAAAAAAwAAAAABAAAAAAAAAAAAAAAAAAAA');
INSERT INTO txhistory VALUES ('bd486dbdd02d460817671c4a5a7e9d6e865ca29cb41e62d7aaf70a2fee5b36de', 4, 1, 'AAAAAK6jei3jmoI8TGlD/egc37PXtHKKzWV8wViZBaCu5L5MAAAAZAAAAAIAAAABAAAAAAAAAAAAAAABAAAAAAAAAAYAAAABVVNEAAAAAAC1uBdHoTugMvQtD7BhIL3Ne9dVPfGI+Ji5JvUO+ZAt73//////////AAAAAAAAAAGu5L5MAAAAQB9kmKW2q3v7Qfy8PMekEb1TTI5ixqkI0BogXrOt7gO162Qbkh2dSTUfeDovc0PAafhDXxthVAlsLujlBmyjBAY=', 'vUhtvdAtRggXZxxKWn6dboZcopy0HmLXqvcKL+5bNt4AAAAAAAAAZAAAAAAAAAABAAAAAAAAAAYAAAAAAAAAAA==', 'AAAAAAAAAAEAAAACAAAAAAAAAAQAAAABAAAAAK6jei3jmoI8TGlD/egc37PXtHKKzWV8wViZBaCu5L5MAAAAAVVTRAAAAAAAtbgXR6E7oDL0LQ+wYSC9zXvXVT3xiPiYuSb1DvmQLe8AAAAAAAAAAH//////////AAAAAAAAAAAAAAAAAAAAAQAAAAQAAAAAAAAAAK6jei3jmoI8TGlD/egc37PXtHKKzWV8wViZBaCu5L5MAAAAAlQL45wAAAACAAAAAQAAAAEAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAA');
INSERT INTO txhistory VALUES ('b55d768a4e8e712da20efdee0e7d85f02948f9b6fd3ef2daefd3a5a147ecd63d', 5, 1, 'AAAAAG5oJtVdnYOVdZqtXpTHBtbcY0mCmfcBIKEgWnlvFIhaAAAAZAAAAAIAAAABAAAAAAAAAAAAAAABAAAAAAAAAAYAAAABVVNEAAAAAAC1uBdHoTugMvQtD7BhIL3Ne9dVPfGI+Ji5JvUO+ZAt7wAAAAlQL5AAAAAAAAAAAAFvFIhaAAAAQBlpm/6rv5JvbN2AKUSlH+4idIlX0cM678QXxK+il0u7z3KLORdzKSkLnS5WdLZlAB6iDmoKI5WbydQLktNtDQA=', 'tV12ik6OcS2iDv3uDn2F8ClI+bb9PvLa79OloUfs1j0AAAAAAAAAZAAAAAAAAAABAAAAAAAAAAYAAAAAAAAAAA==', 'AAAAAAAAAAEAAAACAAAAAAAAAAUAAAABAAAAAG5oJtVdnYOVdZqtXpTHBtbcY0mCmfcBIKEgWnlvFIhaAAAAAVVTRAAAAAAAtbgXR6E7oDL0LQ+wYSC9zXvXVT3xiPiYuSb1DvmQLe8AAAAAAAAAAAAAAAlQL5AAAAAAAAAAAAAAAAAAAAAAAQAAAAUAAAAAAAAAAG5oJtVdnYOVdZqtXpTHBtbcY0mCmfcBIKEgWnlvFIhaAAAAAlQL45wAAAACAAAAAQAAAAEAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAA');
INSERT INTO txhistory VALUES ('3b666a253313fc7a0d241ee28064eec78aaa5ebd0a7c0ae7f85259e80fad029f', 6, 1, 'AAAAALW4F0ehO6Ay9C0PsGEgvc1711U98Yj4mLkm9Q75kC3vAAAAZAAAAAIAAAADAAAAAAAAAAAAAAABAAAAAAAAAAcAAAAArqN6LeOagjxMaUP96Bzfs9e0corNZXzBWJkFoK7kvkwAAAABVVNEAAAAAAEAAAAAAAAAAfmQLe8AAABAL6czYFvSBhdVeD4fbXOHuXFa2CDqLpFfc+QJnoiPLt/23YViURGLyfg388FKMKsbNJEgmFsCJjtgl3fj7wr/Aw==', 'O2ZqJTMT/HoNJB7igGTux4qqXr0KfArn+FJZ6A+tAp8AAAAAAAAAZAAAAAAAAAABAAAAAAAAAAcAAAAAAAAAAA==', 'AAAAAAAAAAEAAAACAAAAAwAAAAQAAAABAAAAAK6jei3jmoI8TGlD/egc37PXtHKKzWV8wViZBaCu5L5MAAAAAVVTRAAAAAAAtbgXR6E7oDL0LQ+wYSC9zXvXVT3xiPiYuSb1DvmQLe8AAAAAAAAAAH//////////AAAAAAAAAAAAAAAAAAAAAQAAAAYAAAABAAAAAK6jei3jmoI8TGlD/egc37PXtHKKzWV8wViZBaCu5L5MAAAAAVVTRAAAAAAAtbgXR6E7oDL0LQ+wYSC9zXvXVT3xiPiYuSb1DvmQLe8AAAAAAAAAAH//////////AAAAAQAAAAAAAAAA');
INSERT INTO txhistory VALUES ('3f2aa00ba539e24ba9c0ba62f50318d8c7180f2d6757cc76e9984055c5e19ff4', 7, 1, 'AAAAALW4F0ehO6Ay9C0PsGEgvc1711U98Yj4mLkm9Q75kC3vAAAAZAAAAAIAAAAEAAAAAAAAAAAAAAABAAAAAAAAAAcAAAAAbmgm1V2dg5V1mq1elMcG1txjSYKZ9wEgoSBaeW8UiFoAAAABVVNEAAAAAAEAAAAAAAAAAfmQLe8AAABA1TAQBu/2f7XHs/ctAJ5W7Ytk4jvQBopdO05zkSQoS8piu1mZm/tTvDTXEq/QUufpt/E8NBgKtNpcJXuMv5aPCw==', 'PyqgC6U54kupwLpi9QMY2McYDy1nV8x26ZhAVcXhn/QAAAAAAAAAZAAAAAAAAAABAAAAAAAAAAcAAAAAAAAAAA==', 'AAAAAAAAAAEAAAACAAAAAwAAAAUAAAABAAAAAG5oJtVdnYOVdZqtXpTHBtbcY0mCmfcBIKEgWnlvFIhaAAAAAVVTRAAAAAAAtbgXR6E7oDL0LQ+wYSC9zXvXVT3xiPiYuSb1DvmQLe8AAAAAAAAAAAAAAAlQL5AAAAAAAAAAAAAAAAAAAAAAAQAAAAcAAAABAAAAAG5oJtVdnYOVdZqtXpTHBtbcY0mCmfcBIKEgWnlvFIhaAAAAAVVTRAAAAAAAtbgXR6E7oDL0LQ+wYSC9zXvXVT3xiPiYuSb1DvmQLe8AAAAAAAAAAAAAAAlQL5AAAAAAAQAAAAAAAAAA');
INSERT INTO txhistory VALUES ('3ce9fc1159c25adc62c9686792cd41f06908280b899744057856db33bafe75de', 8, 1, 'AAAAALW4F0ehO6Ay9C0PsGEgvc1711U98Yj4mLkm9Q75kC3vAAAAZAAAAAIAAAAFAAAAAAAAAAAAAAABAAAAAAAAAAcAAAAAbmgm1V2dg5V1mq1elMcG1txjSYKZ9wEgoSBaeW8UiFoAAAABVVNEAAAAAAAAAAAAAAAAAfmQLe8AAABASafHp/zp11tF81MRvbAnx9gQNTXdLW4DmoIofkgoG+jJw/Xj/k+N5WvSjqGrGF33uB6KnD+wAfQIhf0/DlxpBQ==', 'POn8EVnCWtxiyWhnks1B8GkIKAuJl0QFeFbbM7r+dd4AAAAAAAAAZAAAAAAAAAABAAAAAAAAAAcAAAAAAAAAAA==', 'AAAAAAAAAAEAAAACAAAAAwAAAAcAAAABAAAAAG5oJtVdnYOVdZqtXpTHBtbcY0mCmfcBIKEgWnlvFIhaAAAAAVVTRAAAAAAAtbgXR6E7oDL0LQ+wYSC9zXvXVT3xiPiYuSb1DvmQLe8AAAAAAAAAAAAAAAlQL5AAAAAAAQAAAAAAAAAAAAAAAQAAAAgAAAABAAAAAG5oJtVdnYOVdZqtXpTHBtbcY0mCmfcBIKEgWnlvFIhaAAAAAVVTRAAAAAAAtbgXR6E7oDL0LQ+wYSC9zXvXVT3xiPiYuSb1DvmQLe8AAAAAAAAAAAAAAAlQL5AAAAAAAAAAAAAAAAAA');


--
-- Name: accountdata accountdata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY accountdata
    ADD CONSTRAINT accountdata_pkey PRIMARY KEY (accountid, dataname);


--
-- Name: accounts accounts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY accounts
    ADD CONSTRAINT accounts_pkey PRIMARY KEY (accountid);


--
-- Name: ban ban_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY ban
    ADD CONSTRAINT ban_pkey PRIMARY KEY (nodeid);


--
-- Name: ledgerheaders ledgerheaders_ledgerseq_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY ledgerheaders
    ADD CONSTRAINT ledgerheaders_ledgerseq_key UNIQUE (ledgerseq);


--
-- Name: ledgerheaders ledgerheaders_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY ledgerheaders
    ADD CONSTRAINT ledgerheaders_pkey PRIMARY KEY (ledgerhash);


--
-- Name: offers offers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY offers
    ADD CONSTRAINT offers_pkey PRIMARY KEY (offerid);


--
-- Name: peers peers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY peers
    ADD CONSTRAINT peers_pkey PRIMARY KEY (ip, port);


--
-- Name: publishqueue publishqueue_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY publishqueue
    ADD CONSTRAINT publishqueue_pkey PRIMARY KEY (ledger);


--
-- Name: pubsub pubsub_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY pubsub
    ADD CONSTRAINT pubsub_pkey PRIMARY KEY (resid);


--
-- Name: scpquorums scpquorums_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY scpquorums
    ADD CONSTRAINT scpquorums_pkey PRIMARY KEY (qsethash);


--
-- Name: signers signers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY signers
    ADD CONSTRAINT signers_pkey PRIMARY KEY (accountid, publickey);


--
-- Name: storestate storestate_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY storestate
    ADD CONSTRAINT storestate_pkey PRIMARY KEY (statename);


--
-- Name: trustlines trustlines_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY trustlines
    ADD CONSTRAINT trustlines_pkey PRIMARY KEY (accountid, issuer, assetcode);


--
-- Name: txfeehistory txfeehistory_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY txfeehistory
    ADD CONSTRAINT txfeehistory_pkey PRIMARY KEY (ledgerseq, txindex);


--
-- Name: txhistory txhistory_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY txhistory
    ADD CONSTRAINT txhistory_pkey PRIMARY KEY (ledgerseq, txindex);


--
-- Name: accountbalances; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX accountbalances ON accounts USING btree (balance) WHERE (balance >= 1000000000);


--
-- Name: buyingissuerindex; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX buyingissuerindex ON offers USING btree (buyingissuer);


--
-- Name: histbyseq; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX histbyseq ON txhistory USING btree (ledgerseq);


--
-- Name: histfeebyseq; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX histfeebyseq ON txfeehistory USING btree (ledgerseq);


--
-- Name: ledgersbyseq; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ledgersbyseq ON ledgerheaders USING btree (ledgerseq);


--
-- Name: priceindex; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX priceindex ON offers USING btree (price);


--
-- Name: scpenvsbyseq; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX scpenvsbyseq ON scphistory USING btree (ledgerseq);


--
-- Name: scpquorumsbyseq; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX scpquorumsbyseq ON scpquorums USING btree (lastledgerseq);


--
-- Name: sellingissuerindex; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX sellingissuerindex ON offers USING btree (sellingissuer);


--
-- Name: signersaccount; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX signersaccount ON signers USING btree (accountid);


--
-- PostgreSQL database dump complete
--

