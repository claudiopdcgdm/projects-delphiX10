--
-- PostgreSQL database dump
--

-- Dumped from database version 10.16
-- Dumped by pg_dump version 10.16

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
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- Name: insertendereco(integer, integer, integer, character varying, numeric, numeric, character varying, integer, numeric); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.insertendereco(area integer, rua integer, nivel integer, nome character varying, largura numeric, comprimento numeric, etiqueta character varying, vao integer, altura numeric) RETURNS void
    LANGUAGE plpgsql
    AS $$
begin
	insert into endereco values (default, area,rua,nivel,nome,largura,comprimento,etiqueta,vao,altura);
end;
$$;


ALTER FUNCTION public.insertendereco(area integer, rua integer, nivel integer, nome character varying, largura numeric, comprimento numeric, etiqueta character varying, vao integer, altura numeric) OWNER TO postgres;

--
-- Name: insertpedidosaida(character varying, character varying, date, character varying, character varying, character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.insertpedidosaida(numero character varying, descricao character varying, datapedido date, destino character varying, status character varying, prioridade character varying) RETURNS void
    LANGUAGE plpgsql
    AS $$
begin
	insert into pedidosaida values (default, numero,descricao,datapedido,destino,status,prioridade);
end;
$$;


ALTER FUNCTION public.insertpedidosaida(numero character varying, descricao character varying, datapedido date, destino character varying, status character varying, prioridade character varying) OWNER TO postgres;

--
-- Name: insertproduto(character varying, date, real, character varying, character varying, character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.insertproduto(descricao character varying, datacadastro date, peso real, ean character varying, tipobaixa character varying, sku character varying) RETURNS void
    LANGUAGE plpgsql
    AS $$
begin
	insert into produto values (default, descricao,datacadastro,peso,ean,tipobaixa,sku);
end;
$$;


ALTER FUNCTION public.insertproduto(descricao character varying, datacadastro date, peso real, ean character varying, tipobaixa character varying, sku character varying) OWNER TO postgres;

--
-- Name: insertprodutoendereco(date, integer, integer, integer, integer, integer, date, date); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.insertprodutoendereco(dataentrada date, codigoproduto integer, codigoendereco integer, saldo integer, qtentrada integer, qtsaida integer, datautimasaida date, datavencimento date) RETURNS void
    LANGUAGE plpgsql
    AS $$
begin
	insert into produtoendereco 
	values (
		default,
		dataentrada,
		codigoProduto,
		codigoEndereco,
		saldo,
		qtEntrada,
		qtSaida,
		datautimasaida,
		datavencimento 
		);
end;
$$;


ALTER FUNCTION public.insertprodutoendereco(dataentrada date, codigoproduto integer, codigoendereco integer, saldo integer, qtentrada integer, qtsaida integer, datautimasaida date, datavencimento date) OWNER TO postgres;

--
-- Name: insertseparacao(integer, integer, integer, integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.insertseparacao(codigopedidosaida integer, codigoproduto integer, codigoendereco integer, quantidadesaida integer, codigoprodutoendereco integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
begin
	--insere monta tabela de separação
	insert into separacao values (default,default,codigopedidosaida,codigoproduto,codigoendereco,quantidadesaida);
	
	--atuliza status do pedido
	update pedidosaida ps set "STATUS"='Em separação' WHERE "CODIGO" = codigopedidosaida;
	
	--atualiza quantidadesaida e dataUltsaida eo saldo na tabela produtoendereco
	update produtoendereco  
	set 
		"qtdSaida"= "qtdSaida" + quantidadesaida, 
		"datautimasaida"=current_date
	WHERE
		"codigo"=codigoprodutoendereco AND "codigoproduto"=codigoproduto 
		AND "codigoendereco"=codigoendereco;
	
	--atualiza saldo na tabela produtoendereco
	update produtoendereco  
	set 
		"saldo"= "qtdEntrada" - "qtdSaida"
	WHERE
		"codigo"=codigoprodutoendereco AND "codigoproduto"=codigoproduto 
		AND "codigoendereco"=codigoendereco;
end;
$$;


ALTER FUNCTION public.insertseparacao(codigopedidosaida integer, codigoproduto integer, codigoendereco integer, quantidadesaida integer, codigoprodutoendereco integer) OWNER TO postgres;

--
-- Name: insertseparacao_bkp(integer, integer, integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.insertseparacao_bkp(codigopedidosaida integer, codigoproduto integer, codigoendereco integer, quantidadesaida integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
begin
	insert into separacao values (default,default,codigopedidosaida,codigoproduto,codigoendereco,quantidadesaida);
end;
$$;


ALTER FUNCTION public.insertseparacao_bkp(codigopedidosaida integer, codigoproduto integer, codigoendereco integer, quantidadesaida integer) OWNER TO postgres;

--
-- Name: selectendereco(character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.selectendereco(filtro character varying) RETURNS TABLE(codigo integer, nome character varying, etiqueta character varying, area integer, rua integer, nivel integer, vao integer, largura numeric, comprimento numeric, altura integer)
    LANGUAGE plpgsql
    AS $$
begin

      IF(filtro = 'x' ) THEN
	return query
		select
		  "CODIGO",
		  "NOME",
		  "ETIQUETA",
		  "AREA",
		  "RUA",
		  "NIVEL",
		  "VAO",
		  "LARGURA",
		  "COMPRIMENTO",
		  "ALTURA"
		from endereco limit 500;
      ELSE
	return query
		select
		  "CODIGO",
		  "NOME",
		  "ETIQUETA",
		  "AREA",
		  "RUA",
		  "NIVEL",
		  "VAO",
		  "LARGURA",
		  "COMPRIMENTO",
		  "ALTURA"
		from endereco 
		  where "NOME"=filtro
		  or "ETIQUETA"=filtro
		LIMIT 500;
      
      END IF;
end;
$$;


ALTER FUNCTION public.selectendereco(filtro character varying) OWNER TO postgres;

--
-- Name: selectpedidosaida(character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.selectpedidosaida(filtro character varying) RETURNS TABLE(codigo integer, numero character varying, descricao character varying, datapedido date, destino character varying, status character varying, prioridade character varying)
    LANGUAGE plpgsql
    AS $$
begin

      IF(filtro = 'x' ) THEN
	return query
		select
		  "CODIGO",
		  "NUMERO",
		  "DESCRICAO",
		  "DATAPEDIDO",
		  "DESTINO",
		  "STATUS",
		  "PRIORIDADE"
		from pedidosaida limit 500;
      ELSE
	return query
		select
		  "CODIGO",
		  "NUMERO",
		  "DESCRICAO",
		  "DATAPEDIDO",
		  "DESTINO",
		  "STATUS",
		  "PRIORIDADE"
		from pedidosaida 
		  where "NUMERO"=filtro
		  or "DESCRICAO"=filtro
		LIMIT 500;
      END IF;
end;
$$;


ALTER FUNCTION public.selectpedidosaida(filtro character varying) OWNER TO postgres;

--
-- Name: selectpedidosaidadetalhe(character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.selectpedidosaidadetalhe(filtro character varying) RETURNS TABLE(codigopedido integer, numeropedido character varying, codigopedidoitem integer, quantidadeitem integer, codigoproduto integer, sku character varying, descricaoproduto character varying, tipobaixa character varying, codigoendereco integer, nomeendereco character varying, etiquetaendereco character varying)
    LANGUAGE plpgsql
    AS $$
begin
      IF(filtro = 'x' ) THEN
		return query
			SELECT
				ps."CODIGO",
				ps."NUMERO",
				pd."CODIGO",
				pd."QUANTIDADE",
				p."CODIGO",
				p."SKU",
				p."DESCRICAO",
				p."TIPOBAIXA",
				e."CODIGO",
				e."NOME",
				e."ETIQUETA"
			FROM pedidosaidadetalhe pd 
			INNER JOIN 
				pedidosaida ps ON pd."PEDIDOSAIDA" = ps."CODIGO"
			INNER JOIN 
				produto p ON pd."PRODUTO" = p."CODIGO"
			INNER JOIN 
				endereco e ON pd."ENDERECO" = e."CODIGO"
			WHERE
				ps."CODIGO" = filtro;
      ELSE
		return query
			SELECT
				ps."CODIGO",
				ps."NUMERO",
				pd."CODIGO",
				pd."QUANTIDADE",
				p."CODIGO",
				p."SKU",
				p."DESCRICAO",
				p."TIPOBAIXA",
				e."CODIGO",
				e."NOME",
				e."ETIQUETA"
			FROM pedidosaidadetalhe pd 
			INNER JOIN 
				pedidosaida ps ON pd."PEDIDOSAIDA" = ps."CODIGO"
			INNER JOIN 
				produto p ON pd."PRODUTO" = p."CODIGO"
			INNER JOIN
				endereco e ON pd."ENDERECO" = e."CODIGO"
			WHERE
				p."SKU" = filtro or e."ETIQUETA" = filtro;
      END IF;
end;
$$;


ALTER FUNCTION public.selectpedidosaidadetalhe(filtro character varying) OWNER TO postgres;

--
-- Name: selectpedidosaidadetalhe2(character varying, character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.selectpedidosaidadetalhe2(filtro1 character varying, filtro2 character varying) RETURNS TABLE(codigopedido integer, numeropedido character varying, codigopedidoitem integer, quantidadeitem integer, codigoproduto integer, sku character varying, descricaoproduto character varying, tipobaixa character varying, codigoendereco integer, nomeendereco character varying, etiquetaendereco character varying)
    LANGUAGE plpgsql
    AS $$
begin

if filtro2='x' then
	return query
		SELECT
			ps."CODIGO",
			ps."NUMERO",
			pd."CODIGO",
			pd."QUANTIDADE",
			p."CODIGO",
			p."SKU",
			p."DESCRICAO",
			p."TIPOBAIXA",
			e."CODIGO",
			e."NOME",
			e."ETIQUETA"
		FROM pedidosaidadetalhe pd 
		INNER JOIN 
			pedidosaida ps ON pd."PEDIDOSAIDA" = ps."CODIGO"
		INNER JOIN 
			produto p ON pd."PRODUTO" = p."CODIGO"
		LEFT JOIN 
			endereco e ON pd."ENDERECO" = e."CODIGO"
		WHERE
			ps."NUMERO" = filtro1;
else
	return query
		SELECT
			ps."CODIGO",
			ps."NUMERO",
			pd."CODIGO",
			pd."QUANTIDADE",
			p."CODIGO",
			p."SKU",
			p."DESCRICAO",
			p."TIPOBAIXA",
			e."CODIGO",
			e."NOME",
			e."ETIQUETA"
		FROM pedidosaidadetalhe pd 
		INNER JOIN 
			pedidosaida ps ON pd."PEDIDOSAIDA" = ps."CODIGO"
		INNER JOIN 
			produto p ON pd."PRODUTO" = p."CODIGO"
		LEFT JOIN 
			endereco e ON pd."ENDERECO" = e."CODIGO"
		WHERE
			ps."NUMERO" = filtro1 AND p."SKU"=filtro2;

end if;
	
end;
$$;


ALTER FUNCTION public.selectpedidosaidadetalhe2(filtro1 character varying, filtro2 character varying) OWNER TO postgres;

--
-- Name: selectproduto(character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.selectproduto(filtro character varying) RETURNS TABLE(codigo integer, sku character varying, ean character varying, descricao character varying, tipobaixa character varying, peso numeric, datacadastro date)
    LANGUAGE plpgsql
    AS $$
begin

      IF(filtro = 'x' ) THEN
	return query
		select
		  "CODIGO",
		  "SKU",
		  "EAN",
		  "DESCRICAO",
		  "TIPOBAIXA",
		  "PESO",
		  "DATACADASTRO"
		from produto 
		order by "DESCRICAO"
		LIMIT 500;
      ELSE
	return query
		select
		  "CODIGO",
		  "SKU",
		  "EAN",
		  "DESCRICAO",
		  "TIPOBAIXA",
		  "PESO",
		  "DATACADASTRO"
		from produto 
		  where "SKU"=filtro
		  or "DESCRICAO" like '%'||filtro||'%'
		  or "EAN"=filtro
		order by "DESCRICAO"
		LIMIT 500;
		
      END IF;
end;
$$;


ALTER FUNCTION public.selectproduto(filtro character varying) OWNER TO postgres;

--
-- Name: selectprodutoendereco(character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.selectprodutoendereco(filtro character varying) RETURNS TABLE(sku character varying, ean character varying, descricao character varying, tipobaixa character varying, nome_endereco character varying, etiqueta character varying, codigo integer, dataentrada date, produto integer, endereco integer, saldo integer, quantidade_entrada integer, quantidade_saida integer, dataultimasaida date, datavencimento date)
    LANGUAGE plpgsql
    AS $$
begin
	if filtro = 'x' then
	return query 
		SELECT 
			p."SKU",
			p."EAN",
			p."DESCRICAO",
			p."TIPOBAIXA",
			e."NOME",
			e."ETIQUETA",
			pe.*	
		FROM 
			produtoendereco pe, endereco e, produto p
		WHERE 
			pe."codigoEndereco" = e."CODIGO"
		AND
			pe."codigoProduto" = p."CODIGO"
		ORDER BY p."DESCRICAO" ASC
		LIMIT 500;
	else
	return query
		SELECT 
			p."SKU",
			p."EAN",
			p."DESCRICAO",
			p."TIPOBAIXA",
			e."NOME",
			e."ETIQUETA",
			pe.*	
		FROM 
			produtoendereco pe, endereco e, produto p
		WHERE 
			pe."codigoEndereco" = e."CODIGO"
		AND
			pe."codigoProduto" = p."CODIGO"
		AND
			p."SKU"=filtro
		ORDER BY p."DESCRICAO" ASC
		LIMIT 500;
	end if;
end;
$$;


ALTER FUNCTION public.selectprodutoendereco(filtro character varying) OWNER TO postgres;

--
-- Name: selectprodutoendereco_bkp(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.selectprodutoendereco_bkp() RETURNS TABLE(sku character varying, ean character varying, descricao character varying, tipobaixa character varying, nome_endereco character varying, etiqueta character varying, codigo integer, dataentrada date, produto integer, endereco integer, saldo integer, quantidade_entrada integer, quantidade_saida integer, dataultimasaida date, datavencimento date)
    LANGUAGE plpgsql
    AS $$
begin
	return query 
	SELECT 
		
		p."SKU",
		p."EAN",
		p."DESCRICAO",
		p."TIPOBAIXA",
		e."NOME",
		e."ETIQUETA",
		pe.*	
		
	FROM 
		produtoendereco pe, endereco e, produto p
	WHERE 
		pe."codigoEndereco" = e."CODIGO"
	AND
		pe."codigoProduto" = p."CODIGO"
	ORDER BY pe.codigo DESC
	LIMIT 50;
		
end;
$$;


ALTER FUNCTION public.selectprodutoendereco_bkp() OWNER TO postgres;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: produto; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.produto (
    "CODIGO" integer NOT NULL,
    "DESCRICAO" character varying(100) NOT NULL,
    "DATACADASTRO" date NOT NULL,
    "PESO" numeric(5,0) NOT NULL,
    "EAN" character varying(13) NOT NULL,
    "TIPOBAIXA" character varying(4) NOT NULL,
    "SKU" character varying(15)
);


ALTER TABLE public.produto OWNER TO postgres;

--
-- Name: TABLE produto; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.produto IS 'TABLE FOR STORE REGISTER PRODUTOS';


--
-- Name: selectprodutofilter(character varying, character varying, character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.selectprodutofilter(sku character varying, descricao character varying, ean character varying) RETURNS SETOF public.produto
    LANGUAGE plpgsql
    AS $$
begin
	return query 
	select 
	    CODIGO,
	    SKU,
	    EAN,
	    DESCRICAO,
	    TIPOBAIXA,
	    PESO,
	    DATACADASTRO
	from produto
	where "SKU" like "%sku%"
	or "DESCRICAO" like "%descricao%"
	or "EAN" like "%ean%";
end;
$$;


ALTER FUNCTION public.selectprodutofilter(sku character varying, descricao character varying, ean character varying) OWNER TO postgres;

--
-- Name: selectrelseparacao(character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.selectrelseparacao(numeropedido character varying) RETURNS TABLE(numeroseparacao integer, numero_pedido character varying, destino character varying, datapedido date, prioridade character varying, sku character varying, descricao character varying, tipobaixa character varying, nome character varying, endereco_coleta character varying, quantidadesaida integer)
    LANGUAGE plpgsql
    AS $$
begin
	return query
		SELECT 
		SEP."NUMEROSEPARACAO", 
		PS."NUMERO" AS "NUMERO_PEDIDO",
		PS."DESTINO",
		PS."DATAPEDIDO",
		PS."PRIORIDADE",
		PR."SKU",
		PR."DESCRICAO",
		PR."TIPOBAIXA",
		EN."NOME",
		EN."ETIQUETA" AS "ENDERECO_COLETA",
		SEP."QUANTIDADESAIDA"
	FROM separacao SEP
		JOIN pedidosaida PS ON SEP."CODIGOPEDIDOSAIDA" = PS."CODIGO"
		JOIN produto PR ON SEP."CODIGOPRODUTO" = PR."CODIGO"
		JOIN endereco EN ON SEP."CODIGOENDERECO" = EN."CODIGO"
	WHERE
		PS."NUMERO" = numeropedido;
		
end;
$$;


ALTER FUNCTION public.selectrelseparacao(numeropedido character varying) OWNER TO postgres;

--
-- Name: updateendereco(integer, integer, integer, character varying, numeric, numeric, character varying, integer, numeric, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.updateendereco(area integer, rua integer, nivel integer, nome character varying, largura numeric, comprimento numeric, etiqueta character varying, vao integer, altura numeric, codigo integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
begin
	UPDATE endereco SET 
		"AREA" = area,
		"RUA"=rua,
		"NIVEL"=nivel,
		"NOME"=nome,
		"LARGURA"=largura,
		"COMPRIMENTO"=comprimento,
		"ETIQUETA"=etiqueta,
		"VAO"=vao,
		"ALTURA"=altura
	WHERE
		"CODIGO"=codigo;
end;
$$;


ALTER FUNCTION public.updateendereco(area integer, rua integer, nivel integer, nome character varying, largura numeric, comprimento numeric, etiqueta character varying, vao integer, altura numeric, codigo integer) OWNER TO postgres;

--
-- Name: updatepedidosaida(character varying, character varying, date, character varying, character varying, character varying, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.updatepedidosaida(numero character varying, descricao character varying, datapedido date, destino character varying, status character varying, prioridade character varying, codigo integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
begin
	UPDATE pedidosaida SET 
		"NUMERO" = numero,
		"DESCRICAO"=descricao,
		"DATAPEDIDO"=datapedido,
		"DESTINO"=destino,
		"STATUS"=status,
		"PRIORIDADE"=prioridade
	WHERE
		"CODIGO"=codigo;
end;
$$;


ALTER FUNCTION public.updatepedidosaida(numero character varying, descricao character varying, datapedido date, destino character varying, status character varying, prioridade character varying, codigo integer) OWNER TO postgres;

--
-- Name: updateproduto(character varying, date, numeric, character varying, character varying, character varying, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.updateproduto(descricao character varying, datacadastro date, peso numeric, ean character varying, tipobaixa character varying, sku character varying, codigo integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
begin
	UPDATE produto SET 
		"DESCRICAO" = descricao,
		"DATACADASTRO"=datacadastro,
		"PESO"=peso,
		"EAN"=ean,
		"TIPOBAIXA"=tipobaixa,
		"SKU"=sku
		
	WHERE
		"CODIGO"=codigo;
end;
$$;


ALTER FUNCTION public.updateproduto(descricao character varying, datacadastro date, peso numeric, ean character varying, tipobaixa character varying, sku character varying, codigo integer) OWNER TO postgres;

--
-- Name: updateprodutoendereco(date, integer, integer, integer, integer, integer, date, date, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.updateprodutoendereco(_dataentrada date, _codigoproduto integer, _codigoendereco integer, _saldo integer, _qtentrada integer, _qtsaida integer, _datautimasaida date, _datavencimento date, _codigo integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
begin
	UPDATE produtoendereco SET 
		"dataentrada" = _dataentrada,
		"codigoProduto"= _codigoProduto,
		"codigoEndereco"= _codigoEndereco,
		"saldo"= _saldo,
		"qtdEntrada"= _qtEntrada,
		"qtdSaida"= _qtSaida,
		"datautimasaida"= _datautimasaida,
		"datavencimento"= _datavencimento
	WHERE
		"codigo"=_codigo;
end;
$$;


ALTER FUNCTION public.updateprodutoendereco(_dataentrada date, _codigoproduto integer, _codigoendereco integer, _saldo integer, _qtentrada integer, _qtsaida integer, _datautimasaida date, _datavencimento date, _codigo integer) OWNER TO postgres;

--
-- Name: PRODUTO_CODIGO_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."PRODUTO_CODIGO_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."PRODUTO_CODIGO_seq" OWNER TO postgres;

--
-- Name: PRODUTO_CODIGO_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."PRODUTO_CODIGO_seq" OWNED BY public.produto."CODIGO";


--
-- Name: endereco; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.endereco (
    "CODIGO" integer NOT NULL,
    "AREA" integer NOT NULL,
    "RUA" integer NOT NULL,
    "NIVEL" integer NOT NULL,
    "NOME" character varying(25) NOT NULL,
    "LARGURA" numeric(5,0) NOT NULL,
    "COMPRIMENTO" numeric(5,0) NOT NULL,
    "ETIQUETA" character varying(20) NOT NULL,
    "VAO" integer NOT NULL,
    "ALTURA" integer
);


ALTER TABLE public.endereco OWNER TO postgres;

--
-- Name: TABLE endereco; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.endereco IS 'table for regsiter enderecos';


--
-- Name: endereco_codigo_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.endereco ALTER COLUMN "CODIGO" ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.endereco_codigo_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: pedidosaida; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.pedidosaida (
    "CODIGO" integer NOT NULL,
    "NUMERO" character varying NOT NULL,
    "DESCRICAO" character varying,
    "DATAPEDIDO" date NOT NULL,
    "DESTINO" character varying NOT NULL,
    "STATUS" character varying NOT NULL,
    "PRIORIDADE" character varying NOT NULL
);


ALTER TABLE public.pedidosaida OWNER TO postgres;

--
-- Name: pedidosaida_CODIGO_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.pedidosaida ALTER COLUMN "CODIGO" ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public."pedidosaida_CODIGO_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: pedidosaidadetalhe; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.pedidosaidadetalhe (
    "CODIGO" integer NOT NULL,
    "PRODUTO" integer NOT NULL,
    "QUANTIDADE" integer NOT NULL,
    "ENDERECO" integer,
    "PEDIDOSAIDA" integer NOT NULL
);


ALTER TABLE public.pedidosaidadetalhe OWNER TO postgres;

--
-- Name: pedidosaidadetalhe_CODIGO_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.pedidosaidadetalhe ALTER COLUMN "CODIGO" ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public."pedidosaidadetalhe_CODIGO_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: pedidosaidadetalhe_bkp; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.pedidosaidadetalhe_bkp (
    "CODIGO" integer NOT NULL,
    "PRODUTO" integer NOT NULL,
    "QUANTIDADE" integer NOT NULL,
    "ENDERECO" integer,
    "PEDIDOSAIDA" integer NOT NULL
);


ALTER TABLE public.pedidosaidadetalhe_bkp OWNER TO postgres;

--
-- Name: pedidosaidadetalhe_bkp_CODIGO_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.pedidosaidadetalhe_bkp ALTER COLUMN "CODIGO" ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public."pedidosaidadetalhe_bkp_CODIGO_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: produtoendereco; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.produtoendereco (
    codigo integer NOT NULL,
    dataentrada date NOT NULL,
    "codigoProduto" integer NOT NULL,
    "codigoEndereco" integer NOT NULL,
    saldo integer NOT NULL,
    "qtdEntrada" integer NOT NULL,
    "qtdSaida" integer NOT NULL,
    datautimasaida date,
    datavencimento date
);


ALTER TABLE public.produtoendereco OWNER TO postgres;

--
-- Name: produtoEndereco_codigo_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."produtoEndereco_codigo_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."produtoEndereco_codigo_seq" OWNER TO postgres;

--
-- Name: produtoEndereco_codigo_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."produtoEndereco_codigo_seq" OWNED BY public.produtoendereco.codigo;


--
-- Name: separacao; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.separacao (
    "CODIGO" integer NOT NULL,
    "NUMEROSEPARACAO" integer NOT NULL,
    "CODIGOPEDIDOSAIDA" integer NOT NULL,
    "CODIGOPRODUTO" integer NOT NULL,
    "CODIGOENDERECO" integer NOT NULL,
    "QUANTIDADESAIDA" integer NOT NULL,
    "PRODUTOENDERECO" integer
);


ALTER TABLE public.separacao OWNER TO postgres;

--
-- Name: separacao_CODIGO_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.separacao ALTER COLUMN "CODIGO" ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public."separacao_CODIGO_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: separacao_NUMEROSEPARACAO_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.separacao ALTER COLUMN "NUMEROSEPARACAO" ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public."separacao_NUMEROSEPARACAO_seq"
    START WITH 999
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: teste; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.teste (
    codigo1 integer NOT NULL,
    codigo2 integer NOT NULL,
    descricao character varying NOT NULL
);


ALTER TABLE public.teste OWNER TO postgres;

--
-- Name: produto CODIGO; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.produto ALTER COLUMN "CODIGO" SET DEFAULT nextval('public."PRODUTO_CODIGO_seq"'::regclass);


--
-- Name: produtoendereco codigo; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.produtoendereco ALTER COLUMN codigo SET DEFAULT nextval('public."produtoEndereco_codigo_seq"'::regclass);


--
-- Data for Name: endereco; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.endereco ("CODIGO", "AREA", "RUA", "NIVEL", "NOME", "LARGURA", "COMPRIMENTO", "ETIQUETA", "VAO", "ALTURA") FROM stdin;
20	1	1	0	PER-3	2	2	A1-R1-N0-V3	3	2
22	1	1	0	PER-4	120	120	A1-R1-N0-V4	4	120
16	1	1	0	PER-1	1	1	A1-R1-N0-V1	1	1
19	1	1	0	PER-5	1	1	A1-R1-N0-V5	5	1
23	1	1	0	PER-7	1	1	A1-R1-N0-V7	7	1
24	1	1	0	PER-9	1	1	A1-R1-N0-V9	9	1
25	1	1	0	PER-2	1	1	A1-R1-N0-V2	2	1
26	1	1	0	PER-6	1	1	A1-R1-N0-V6	6	1
27	1	1	0	PER-8	1	1	A1-R1-N0-V8	8	1
28	1	1	0	PER-10	1	1	A1-R1-N0-V10	10	1
29	1	2	0	NOR-1	1	1	A1-R2-N0-V1	1	1
30	1	2	0	NOR-2	1	1	A1-R2-N0-V2	2	1
32	1	2	0	NOR-3	1	1	A1-R2-N0-V3	3	1
33	1	2	0	NOR-4	1	1	A1-R2-N0-V4	4	1
35	1	2	0	NOR-5	1	1	A1-R2-N0-V5	5	1
36	1	1	0	TESTE	1	1	A1-R1-N0-V11	11	1
37	1	1	0	NOR-2	1	1	A1-R1-N0-V20	20	1
\.


--
-- Data for Name: pedidosaida; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.pedidosaida ("CODIGO", "NUMERO", "DESCRICAO", "DATAPEDIDO", "DESTINO", "STATUS", "PRIORIDADE") FROM stdin;
22	3000	pedido 3000	2021-05-04	loja 200	Em separação	Normal
23	4000	pedido teste 4000	2021-05-05	loja 300	Em separação	Normal
25	4001	PEDIDO TESTE 4001	2021-05-07	loja 800	Em separação	Baixa
26	4002	teste	2021-05-07	loja 600	Em separação	Media
27	4003	PEDIDO DE TODDY	2021-05-07	loja 600	Em separação	Normal
28	5000	PEDIDO TODDY LJ 100	2021-05-07	loja 100	Em separação	Normal
29	5001	TODDY LOJA 200	2021-05-07	loja 200	Em separação	Normal
30	5502	CERV LOJA 500	2021-05-07	loja 500	Em separação	Normal
31	6000	PED MIOJO LOJA 400	2021-05-07	loja 400	Em separação	Normal
\.


--
-- Data for Name: pedidosaidadetalhe; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.pedidosaidadetalhe ("CODIGO", "PRODUTO", "QUANTIDADE", "ENDERECO", "PEDIDOSAIDA") FROM stdin;
8	13	2	\N	23
14	12	12	\N	23
16	33	23	\N	22
17	33	7	\N	23
20	41	12	\N	25
21	42	5	\N	25
22	33	5	\N	25
23	41	12	\N	26
24	43	23	\N	26
25	47	34	\N	26
26	50	95	\N	27
27	50	5	\N	28
28	50	5	\N	29
29	44	10	\N	30
31	51	10	\N	31
\.


--
-- Data for Name: pedidosaidadetalhe_bkp; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.pedidosaidadetalhe_bkp ("CODIGO", "PRODUTO", "QUANTIDADE", "ENDERECO", "PEDIDOSAIDA") FROM stdin;
\.


--
-- Data for Name: produto; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.produto ("CODIGO", "DESCRICAO", "DATACADASTRO", "PESO", "EAN", "TIPOBAIXA", "SKU") FROM stdin;
41	ESQUEIRO BIC GRANDE	2021-05-05	1	07033091342	FIFO	07033091342
42	CAFÉ SOLÚVEL GRANULADO	2021-05-05	120	7891000613054	FEFO	7891000613054
43	ESPÁTULA DE SILICONE RETA	2021-05-05	12	7898673987703	FIFO	7898673987703
44	CERVEJA ALE CHOCOLATE	2021-05-05	600	7898230715466	FEFO	7898230715466
45	CERVEJA BRAHMA ZERO	2021-05-05	250	7891149104932	FEFO	7891149104932
47	VASSOURA SCOOT	2021-05-05	0	789100060006	FIFO	789100060006
49	ESCORREDOR DE LOUÇAS ROMA PLUS	2021-05-07	0	7896459756130	FIFO	7896459756130
46	JARRA DECATER COM TAMPA	2021-05-05	0	7891017854556	LIFO	7891017854556
48	SKATE QIX HEXAGON	2021-05-05	0	7893435363738	FIFO	7893435363738
50	ACHOCOLATADO TODDY	2021-05-07	1	7894321711478	FEFO	7894321711478
51	MIOJO NISSIN LAMEN	2021-05-07	0	7891079000229	FEFO	7891079000229
14	ACHOCOLATADO NESCAU	2021-04-27	100	7891000053508	FEFO	7891000053508
13	BISC AGUA E SAL BAUDUCCO	2021-04-28	1	7891962026831	FEFO	7891962026831
33	BISC AYMORÉ RECHEADA	2021-04-27	0	7896058257618	FEFO	7896058257618
12	BISC PASSATEMPO NESTLE	2021-04-27	0	7891000241356	FEFO	7891000241356
38	ARROZ CAMIL	2021-05-02	3	7892112234589	FEFO	7892112234589
\.


--
-- Data for Name: produtoendereco; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.produtoendereco (codigo, dataentrada, "codigoProduto", "codigoEndereco", saldo, "qtdEntrada", "qtdSaida", datautimasaida, datavencimento) FROM stdin;
22	2021-05-07	13	20	26	28	2	2021-05-07	2021-05-08
17	2021-05-06	12	20	0	12	12	2021-05-07	2021-05-27
16	2021-05-06	33	20	10	33	23	2021-05-07	2021-05-29
19	2021-05-06	47	30	0	45	45	2021-05-07	2021-05-06
23	2021-05-07	50	36	0	100	100	2021-05-07	2021-10-21
14	2021-05-06	14	16	8	20	12	2021-05-07	2021-05-31
15	2021-05-06	38	16	0	12	12	2021-05-07	2021-05-29
18	2021-05-06	46	29	9	21	12	2021-05-07	2021-05-06
27	2021-05-07	44	25	0	5	5	2021-05-07	2021-05-10
21	2021-05-06	33	22	0	12	12	2021-05-07	2021-05-18
26	2021-05-07	44	16	95	100	5	2021-05-07	2021-05-30
28	2021-05-07	50	16	20	20	0	\N	2021-05-08
25	2021-05-07	50	37	10	10	0	\N	2021-05-10
30	2021-05-07	51	27	0	5	5	2021-05-07	2021-05-08
29	2021-05-07	51	36	5	10	5	2021-05-07	2021-05-10
31	2021-05-07	51	19	23	23	0	\N	2021-05-07
\.


--
-- Data for Name: separacao; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.separacao ("CODIGO", "NUMEROSEPARACAO", "CODIGOPEDIDOSAIDA", "CODIGOPRODUTO", "CODIGOENDERECO", "QUANTIDADESAIDA", "PRODUTOENDERECO") FROM stdin;
23	1021	22	33	22	12	\N
24	1022	22	33	20	11	\N
34	1032	23	13	20	2	\N
35	1033	23	12	20	12	\N
36	1034	23	33	20	7	\N
37	1035	25	33	20	5	\N
38	1036	26	47	30	33	\N
39	1037	27	50	36	95	\N
40	1038	28	50	36	5	\N
41	1039	28	50	16	5	\N
42	1040	29	50	16	5	\N
43	1041	30	44	25	5	\N
44	1042	30	44	16	5	\N
45	1043	31	51	27	5	\N
46	1044	31	51	36	5	\N
\.


--
-- Data for Name: teste; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.teste (codigo1, codigo2, descricao) FROM stdin;
\.


--
-- Name: PRODUTO_CODIGO_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."PRODUTO_CODIGO_seq"', 51, true);


--
-- Name: endereco_codigo_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.endereco_codigo_seq', 37, true);


--
-- Name: pedidosaida_CODIGO_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."pedidosaida_CODIGO_seq"', 31, true);


--
-- Name: pedidosaidadetalhe_CODIGO_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."pedidosaidadetalhe_CODIGO_seq"', 31, true);


--
-- Name: pedidosaidadetalhe_bkp_CODIGO_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."pedidosaidadetalhe_bkp_CODIGO_seq"', 1, false);


--
-- Name: produtoEndereco_codigo_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."produtoEndereco_codigo_seq"', 63, true);


--
-- Name: separacao_CODIGO_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."separacao_CODIGO_seq"', 46, true);


--
-- Name: separacao_NUMEROSEPARACAO_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."separacao_NUMEROSEPARACAO_seq"', 1044, true);


--
-- Name: produto PRODUTO_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.produto
    ADD CONSTRAINT "PRODUTO_pkey" PRIMARY KEY ("CODIGO");


--
-- Name: pedidosaidadetalhe UN_CODPRODUTO_CODPEDIDO; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pedidosaidadetalhe
    ADD CONSTRAINT "UN_CODPRODUTO_CODPEDIDO" UNIQUE ("PRODUTO", "PEDIDOSAIDA");


--
-- Name: produto UN_EAN; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.produto
    ADD CONSTRAINT "UN_EAN" UNIQUE ("EAN");


--
-- Name: endereco UN_ETIQUETA; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.endereco
    ADD CONSTRAINT "UN_ETIQUETA" UNIQUE ("ETIQUETA");


--
-- Name: endereco UN_NOME; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.endereco
    ADD CONSTRAINT "UN_NOME" UNIQUE ("NOME", "ETIQUETA");


--
-- Name: endereco codigo_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.endereco
    ADD CONSTRAINT codigo_pkey PRIMARY KEY ("CODIGO");


--
-- Name: pedidosaidadetalhe codigo_produto_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pedidosaidadetalhe
    ADD CONSTRAINT codigo_produto_pkey PRIMARY KEY ("CODIGO", "PRODUTO");


--
-- Name: pedidosaida pedidosaida_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pedidosaida
    ADD CONSTRAINT pedidosaida_pkey PRIMARY KEY ("CODIGO");


--
-- Name: pedidosaidadetalhe_bkp pedidosaidadetalhe_produto_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pedidosaidadetalhe_bkp
    ADD CONSTRAINT pedidosaidadetalhe_produto_pkey PRIMARY KEY ("CODIGO", "PRODUTO");


--
-- Name: produtoendereco produtoEndereco_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.produtoendereco
    ADD CONSTRAINT "produtoEndereco_pkey" PRIMARY KEY (codigo);


--
-- Name: produto produto_SKU_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.produto
    ADD CONSTRAINT "produto_SKU_key" UNIQUE ("SKU");


--
-- Name: separacao separacao_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.separacao
    ADD CONSTRAINT separacao_pkey PRIMARY KEY ("CODIGO");


--
-- Name: teste teste_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.teste
    ADD CONSTRAINT teste_pkey PRIMARY KEY (codigo1, codigo2);


--
-- Name: pedidosaida un_numero_pedido; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pedidosaida
    ADD CONSTRAINT un_numero_pedido UNIQUE ("NUMERO");


--
-- Name: produtoendereco un_produto_endereco; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.produtoendereco
    ADD CONSTRAINT un_produto_endereco UNIQUE ("codigoProduto", "codigoEndereco");


--
-- Name: fki_FK_PEDIDOSAIDA; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "fki_FK_PEDIDOSAIDA" ON public.pedidosaidadetalhe USING btree ("PEDIDOSAIDA");


--
-- Name: fki_codigoEndereco_fk; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "fki_codigoEndereco_fk" ON public.produtoendereco USING btree ("codigoEndereco");


--
-- Name: fki_codigoProduto_fk; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "fki_codigoProduto_fk" ON public.produtoendereco USING btree ("codigoProduto");


--
-- Name: pedidosaidadetalhe_bkp FK_CODIGOPRODUTO; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pedidosaidadetalhe_bkp
    ADD CONSTRAINT "FK_CODIGOPRODUTO" FOREIGN KEY ("PRODUTO") REFERENCES public.produto("CODIGO");


--
-- Name: pedidosaidadetalhe FK_CODIGOPRODUTO; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pedidosaidadetalhe
    ADD CONSTRAINT "FK_CODIGOPRODUTO" FOREIGN KEY ("PRODUTO") REFERENCES public.produto("CODIGO");


--
-- Name: separacao FK_ENDERECO; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.separacao
    ADD CONSTRAINT "FK_ENDERECO" FOREIGN KEY ("CODIGOENDERECO") REFERENCES public.endereco("CODIGO") NOT VALID;


--
-- Name: pedidosaidadetalhe FK_PEDIDOSAIDA; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pedidosaidadetalhe
    ADD CONSTRAINT "FK_PEDIDOSAIDA" FOREIGN KEY ("PEDIDOSAIDA") REFERENCES public.pedidosaida("CODIGO");


--
-- Name: pedidosaidadetalhe_bkp FK_PEDIDOSAIDA_BKP; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pedidosaidadetalhe_bkp
    ADD CONSTRAINT "FK_PEDIDOSAIDA_BKP" FOREIGN KEY ("PEDIDOSAIDA") REFERENCES public.pedidosaida("CODIGO");


--
-- Name: separacao FK_PEDIDO_SAIDA; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.separacao
    ADD CONSTRAINT "FK_PEDIDO_SAIDA" FOREIGN KEY ("CODIGOPEDIDOSAIDA") REFERENCES public.pedidosaida("CODIGO") NOT VALID;


--
-- Name: separacao FK_PRODUTO; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.separacao
    ADD CONSTRAINT "FK_PRODUTO" FOREIGN KEY ("CODIGOPRODUTO") REFERENCES public.produto("CODIGO") NOT VALID;


--
-- Name: separacao FK_PRODUTO_ENDERECO; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.separacao
    ADD CONSTRAINT "FK_PRODUTO_ENDERECO" FOREIGN KEY ("PRODUTOENDERECO") REFERENCES public.produtoendereco(codigo) NOT VALID;


--
-- Name: produtoendereco codigoEndereco_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.produtoendereco
    ADD CONSTRAINT "codigoEndereco_fk" FOREIGN KEY ("codigoEndereco") REFERENCES public.endereco("CODIGO") NOT VALID;


--
-- Name: produtoendereco codigoProduto_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.produtoendereco
    ADD CONSTRAINT "codigoProduto_fk" FOREIGN KEY ("codigoProduto") REFERENCES public.produto("CODIGO") NOT VALID;


--
-- PostgreSQL database dump complete
--

