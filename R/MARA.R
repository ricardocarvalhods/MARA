
#' Instruções para uso de MySQL
#'
#' Esta função informa passos de como ficar pronto para realizar consultas a um
#' SGBD MySQL (versões 3 ou 5).
#'
#' @return mensagem com instruções.
#' @author Ricardo S. Carvalho
#' @details
#' Esta função não recebe argumentos e retorna um texto que informa os passos para
#' habilitar o uso uma máquina Windows para realização de consultas e inserções
#' de dados em um SGBD MySQL (versões 3 ou 5).
#' @seealso \code{instrucoes.SQLServer}, \code{insertDataIntoDB}, \code{runSQLonDB}
#' @examples
#' # Exibir mensagem com instruções
#' instrucoes.MySQL()
#' @export
instrucoes.MySQL <- function(){
  cat("
  ## PARA SGBD MYSQL
  ##    1) Instalar mysql connector:
  ##       - Para ESFINGE (MySQL 5) -> Instalar 'mysql-connector-odbc-5.3.2-winx64.msi' (VERSÃO COMPLETA)
  ##       - Para LETO (MySQL 3) -> Instalar 'mysql-connector-odbc-3.51.30-winx64.msi' (VERSÃO COMPLETA)
  ##
  ##    2) Executar:
  ##       - install.packages(\"RODBC\")
  ## 
  ##    3) Criar Data Source (Windows)
  ##       - Painel de Controle -> Ferramentas Administrativas -> Configurar fontes de dados (ODBC)
  ##       - Na aba 'Fonte de dados de usuario' clicar em 'Adicionar'
  ##       - Escolher MySQL ODBC Driver (5 para ESFINGE e 3 para LETO)
  ##       - Preencher campos da conexao
  ##       - Campo 'Data Source Name' sera o usado pelo comando do R
  ")
}

#' Instruções para uso de SQL Server
#'
#' Esta função informa passos de como ficar pronto para realizar consultas a um
#' SGBD SQL Server.
#'
#' @return mensagem com instruções.
#' @author Ricardo S. Carvalho
#' @details
#' Esta função não recebe argumentos e retorna um texto que informa os passos para
#' habilitar o uso uma máquina Windows para realização de consultas e inserções
#' de dados em um SGBD SQL Server.
#' @seealso \code{instrucoes.MySQL}, \code{insertDataIntoDB}, \code{runSQLonDB}
#' @examples
#' # Exibir mensagem com instruções
#' instrucoes.SQLServer()
#' @export
instrucoes.SQLServer <- function(){
  cat("
  ## PARA SGBD SQL SERVER
  ##    1) Instalar SQL Server Management Studio
  ##       - Caso ja esteja instalado, conectores estao OK para SQL Server
  ##
  ##    2) Executar:
  ##       - install.packages(\"RODBC\")
  ## 
  ##    3) Criar Data Source (Windows)
  ##       - Painel de Controle -> Ferramentas Administrativas -> Configurar fontes de dados (ODBC)
  ##       - Na aba 'Fonte de dados de usuario' clicar em 'Adicionar'
  ##       - Escolher SQL Server
  ##       - Preencher campos da conexao
  ##       - Campo 'Data Source Name' sera o usado pelo comando do R
  ")
}

conectaDB <- function(nomeConexaoODBC, nomeBanco=NULL){
  # LIBRARIES
  if(!require(RODBC)) {
    install.packages("RODBC")
    library(RODBC)
  }
  
  logins <- readLines('database_logins.txt')
  
  datasource <- grep(nomeConexaoODBC, logins)
  
  if(length(datasource)==0){
    msg <- paste0("\n[ERRO] Não foi encontrado o data source especificado (", 
                nomeConexaoODBC,
                ") no arquivo database_logins.txt armazenado no Working Directory atual (",
                getwd(),
                ")")
    cat(msg)
    return(NULL)
  }
  else {
    usuario <- logins[datasource + 1]
    senha <- logins[datasource + 2]
  
    if(is.null(nomeBanco)){
      conn <- odbcConnect(nomeConexaoODBC, uid=usuario, pwd=senha)
    }
    else {
      conn <- odbcDriverConnect( paste0("Driver=SQL Server; Server=", nomeConexaoODBC, 
                    "; Database=", nomeBanco, "; Uid=", usuario, "; Pwd=", senha, "") )
    }
  
    return(conn)
  }
}

#' Executar SQL em SGBD
#'
#' Esta função se conecta a um SGBD definido por um Data Source configurado e 
#' usa usuário/senha obtidos em arquivo database_logins.txt e executa SQL passado
#' via objeto ou arquivo.
#'
#' @param nomeConexaoODBC nome do Data Source configurado para o SGBD desejado.
#' @param nomeArquivoComSQL nome do arquivo .sql a ser executado. Só executa caso não
#' haja objeto querySQL definido.
#' @param querySQL objeto de texto/character com comando SQL a ser executado.
#' @param padCPFeCNPJ flag que define se deve haver padding de colunas de CPF e/ou CNPJ.
#' @param showSuccessMessage flag que define se a mensagem de sucesso deverá ser exibida.
#' @return um data frame com resultado do SQL.
#' @author Ricardo S. Carvalho
#' @details
#' Esta função inicialmente lê o arquivo database_logins.txt que deve estar na
#' mesma pasta do Working Directory (definido com setwd) e obtém usuário e senha 
#' para o Data Source indicado como argumento. 
#' Em seguida, havendo objeto com SQL em querySQL, o mesmo é executado, caso contrário
#' executa o arquivo .sql em nomeArquivoComSQL.
#' Para flag padCPFeCNPJ setada, o resultado do SQL é tratado para realizar padding de
#' qualquer coluna contendo o texto cpf/CPF/cnpj/CNPJ.
#' Para flag showSuccessMessage setada, havendo sucesso na consulta, a mensagem
#' de sucesso padrão é exibida. Caso sejam executados vários SQLs em sequência,
#' recomenda-se definir showSuccessMessage como FALSE, pois assim somente aparece
#' mensagem em caso de ERRO em algum SQL.
#' @seealso \code{insertDataIntoDB}, \code{instrucoes.SQLServer}, \code{instrucoes.MySQL}
#' @import RODBC
#' @examples
#' # Obter dados do Data Source Esfinge configurado
#' # SQL encontra-se no arquivo de nome "Query_Esfinge_GABCRG_Punidos.sql"
#' dadosESFINGE <- runSQLonDB("Esfinge", "Query_Esfinge_GABCRG_Punidos.sql")
#' @export
runSQLonDB <- function(nomeConexaoODBC, nomeArquivoComSQL=NULL, querySQL=NULL, padCPFeCNPJ=TRUE, showSuccessMessage=TRUE){

  conn <- conectaDB(nomeConexaoODBC)
  
  queryCorruptos <- ""
  if(is.null(querySQL)){
    queryCorruptos <- readChar(nomeArquivoComSQL, file.info(nomeArquivoComSQL)$size)
  }
  else {
    queryCorruptos <- querySQL  
  }
  
  queryResult <- sqlQuery(conn, queryCorruptos)
  odbcClose(conn)
  
  qtd <- nrow(queryResult)  
  
  # Padding de colunas com nome CPF e/ou CNPJ
  if(padCPFeCNPJ && !(is.null(nrow(queryResult))) && nrow(queryResult) != 0){            
    queryResult <- padCPFeCNPJ(queryResult)
  }
  
  # Exibir nr de linhas do SQL
  if(!(is.null(qtd))){
    qtd <- paste(" - [", qtd, " linhas] -", sep="")
  }
  else {
    qtd <- ""
  }
  
  # Mensagens de erro/sucesso
  if(length(queryResult) > 0 && length(grep("ERROR", queryResult)) > 0){
    msg <- paste("\n[ERRO] SQL nao executado: ", queryResult, sep="")
    cat(msg)
  }
  else {
    if(showSuccessMessage){
      msg <- paste("\n[OK]", qtd, " SQL com sucesso: ", sep="")
      cat(msg, substring(queryCorruptos, 0, 200), " (...)")
    }
  }
  
  return(queryResult)
}

#' Inserir dados em tabela de SGBD
#'
#' Esta função se conecta a um SGBD definido por um Data Source configurado e 
#' usa usuário/senha obtidos em arquivo database_logins.txt e insere dados passados
#' na tabela escolhida.
#'
#' @param nomeConexaoODBC nome do Data Source configurado para o SGBD desejado.
#' @param dadosNOVOS data frame com dados a serem inseridos. Deve conter colunas com
#' exatamente os mesmos nomes que as colunas da tabela onde dados serão inseridos 
#' (case sensitive).
#' @param nomeBanco nome do banco de dados do SGBD onde dados serão inseridos.
#' @param nomeTabela nome da tabela do SGBD onde dados serão inseridos.
#' @param verboseInsert flag que define se deve exibir mensagens de inserção do SGBD.
#' @param showSuccessMessage flag que define se a mensagem de sucesso deverá ser exibida.
#' @return mensagem de erro ou sucesso.
#' @author Ricardo S. Carvalho
#' @details
#' Esta função inicialmente lê o arquivo database_logins.txt que deve estar na
#' mesma pasta do Working Directory (definido com setwd) e obtém usuário e senha 
#' para o Data Source indicado como argumento. 
#' Em seguida, insere data frame dadosNOVOS na tabela nomeTabela.
#' O objeto dadosNOVOS deve conter colunas com exatamente os mesmos nomes que as colunas 
#' da tabela onde dados serão inseridos (case sensitive).
#' Para flag verboseInsert setada, as mensagens do SGBD para o insert são exibidas.
#' Para flag showSuccessMessage setada, havendo sucesso na consulta, a mensagem
#' de sucesso padrão é exibida. Caso sejam executados vários inserts em sequência,
#' recomenda-se definir showSuccessMessage como FALSE, pois assim somente aparece
#' mensagem em caso de ERRO em algum insert.
#' @seealso \code{runSQLonDB}, \code{instrucoes.SQLServer}, \code{instrucoes.MySQL}
#' @import RODBC
#' @examples
#' # Inserir data frama df_NatResp usando data source sed-die-bd1-c
#' # na tabela dbo.natresp localizada no dw_mara_stage
#' insertDataIntoDB('sed-die-bd1-c', df_NatResp, 'natresp')
#' @export
insertDataIntoDB <- function(nomeConexaoODBC, dadosNOVOS, nomeBanco=NULL, nomeTabela, verboseInsert=FALSE, showSuccessMessage=TRUE){
  if(nrow(dadosNOVOS) == 0){
    return("[OK] Nao ha novos dados para insercao")
  }
  else {
    conn <- conectaDB(nomeConexaoODBC, nomeBanco)
    
    saveResult <- sqlSave(conn, dadosNOVOS, tablename=nomeTabela, append=TRUE, verbose=verboseInsert, rownames=FALSE)        
    odbcClose(conn)
    if(saveResult == 1){
      if(showSuccessMessage){
        return("[OK] Dados inseridos com sucesso")
      }
    }
    else{
      return("[ERRO] Erro ao inserir dados")
    }
  }
}

padCPFeCNPJ <- function(dados){
  # LIBRARIES
  if(!require(stringr)) {
    install.packages("stringr")
    library(stringr)
  }
  
  # CPF
  nr_col <- c(grep('cpf', names(dados)), grep('CPF', names(dados)))        
  if(length(nr_col) != 0){
    for(c in nr_col){
      dados[is.na(dados[, c]), c] <- '0'
      dados[, c] <- str_pad(dados[, c], width=11, side="left", pad="0")
      dados[dados[, c] == '00000000000', c] <- NA
    }
  }
  
  # CNPJ
  nr_col <- c(grep('cnpj', names(dados)), grep('CNPJ', names(dados)))
  if(length(nr_col) != 0){
    for(c in nr_col){
      dados[is.na(dados[, c]), c] <- '0'
      dados[, c] <- str_pad(dados[, c], width=14, side="left", pad="0")
      dados[dados[, c] == '00000000000000', c] <- NA
    }
  }
  
  return(dados)
}

#' Limpar caracteres de um vetor/coluna
#'
#' Esta função realiza diversas limpezas para um vetor/coluna do tipo character.
#'
#' @param coluna vetor que deve ser limpo.
#' @param removeEspacos flag que define se deve remover completamente os espaços em branco.
#' @param metodoTRANSLIT flag que define se será usado método ASCII/TRANSLIT para limpeza de acentos.
#' Caso seja FALSE usará conversão de latin para ASCII como método para limpeza de acentos.
#' @return vetor limpo.
#' @author Ricardo S. Carvalho
#' @details
#' Esta função realiza as seguintes limpezas: caso flag removeEspacos seja TRUE remove
#' completamente todos os espaços do vetor; remove acentuação, por um de dois métodos 
#' (ASCII//TRANSLIT ou latin para ASCII) escolhido pelo flag metodoTRANSLIT; remove
#' espaços que ficam no começo ou fim; remove pontuações; e transforma textos em maiúsculo.
#' @seealso \code{getDFcomDummyCols}, \code{discretizaComCutPoints}
#' @import stringr
#' @examples
#' # Limpar coluna nm_pessoa do data frama DFRFB
#' # Não removendo espaços em branco e usando método TRANSLIT de remoção de acentuação
#' DFRFB$nm_pessoa <- limpaCaracteres(DFRFB$nm_pessoa)
#' # Caso não funcione a limpeza com método TRANSLIT, tentar conversão latin1 para ASCII
#' DFRFB$nm_pessoa <- limpaCaracteres(DFRFB$nm_pessoa, metodoTRANSLIT=FALSE)
#' @export
limpaCaracteres <- function(coluna, removeEspacos=FALSE, metodoTRANSLIT=TRUE){
  # LIBRARIES
  if(!require(stringr)) {
    install.packages("stringr")
    library(stringr)
  }
  
  # Remover espaco dos nomes das colunas
  if(removeEspacos){
    coluna <- gsub(" ", "", coluna)
  }
  
  # Remover acentuacao dos nomes das colunas
  if(metodoTRANSLIT){
    coluna <- iconv(coluna, to="ASCII//TRANSLIT")
  }
  else {
    Encoding(coluna) <- 'latin1'
    coluna <- iconv(coluna, 'latin1', 'ASCII', '')
  }
  
  # Remove espacos do comeco e do fim
  coluna <- str_trim(coluna)
  
  # Remover pontuacoes dos nomes das colunas
  coluna <- gsub("([_])|[[:punct:]]", "\\1", coluna)
  
  # Transformar todos em maiusculas
  coluna <- toupper(coluna)
  
  return(coluna)
}

#' Transforma colunas character/factor em colunas dummy
#'
#' Esta função transforma colunas selecionadas em dummy e retorna o data frame
#' original combinado (cbind) com as colunas dummy.
#'
#' @param df.completo data frame completo, com todas as colunas.
#' @param cols.to.dummy vetor com números indicando quais colunas de df.completo 
#' deverão ser transformadas em dummy.
#' @return df.completo combinado (cbind) com colunas transformadas em dummy.
#' @author Ricardo S. Carvalho
#' @details
#' Esta função transforma em dummy as colunas do df.completo nas posições definidas em 
#' cols.to.dummy e retorna o data frame original df.completo combinado (cbind) com as 
#' colunas transformadas em dummy.
#' @seealso \code{limpaCaracteres}, \code{discretizaComCutPoints}
#' @import dummies
#' @examples
#' # Obter DFRFB junto com colunas 3,6 e 11 trasnformadas em dummy
#' DFRFB_com_dummy <- getDFcomDummyCols(DFRFB, c(3,6,11))
#' @export
getDFcomDummyCols <- function(df.completo, cols.to.dummy){
  # LIBRARIES
  if(!require(dummies)) {
    install.packages("dummies")
    library(dummies)
  }
  
  df.completo.to.dummy <- as.data.frame(df.completo[,cols.to.dummy])
  names(df.completo.to.dummy) <- names(df.completo)[cols.to.dummy]
  df.completo.dummy <- dummy.data.frame(df.completo.to.dummy, sep="_", drop=T)
  
  df.completo <- cbind(df.completo, df.completo.dummy)
  
  return(df.completo)
}

#' Discretiza coluna usando valores de cut points
#'
#' Esta função transforma uma coluna numérica em factor, separando os valores da
#' coluna a partir dos cut points definidos.
#'
#' @param coluna coluna a ser discretizada.
#' @param cut.points pontos de corte para separar valores da coluna.
#' @return factor com coluna discretizada por cut.points.
#' @author Ricardo S. Carvalho
#' @details
#' Esta função transforma uma coluna numérica em factor, separando os valores da
#' coluna a partir dos cut points definidos.
#' Portanto, esta função não define os cut.points, ela só os aplica em uma coluna
#' para obter o resultado discretizado.
#' Os limites inferior e superio usados são -Inf e Inf.
#' Os intervalos são sempre definidos excluindo o menor valor e incluindo o maior valor.
#' @seealso \code{limpaCaracteres}, \code{getDFcomDummyCols}
#' @examples
#' # Dados do exemplo
#' xcoluna <- c(rep(1,10), rep(100,10), rep(1000,10))
#' xclasse <- c(rep(0,10), rep(1,10), rep(0,10))
#' dados <- cbind(xcoluna, xclasse)
#' # Realizar discretização via CAIM para obter cut.points
#' # É método supervisionado, portanto, discretiza xcoluna "vendo" xclasse
#' require(discretization)
#' discret <- disc.Topdown(dados, method = 1) # CAIM
#' # Extrair cut.points
#' cut.points <- discret$cutp[[1]]
#' # Discretizar xcoluna com cut.points
#' xcoluna_disc <- discretizaComCutPoints(xcoluna, cut.points)
#' @export
discretizaComCutPoints <- function(coluna, cut.points) {  
  if(length(cut.points) > 1 & cut.points[1] == cut.points[2]){
    qf <- factor(coluna)
  }
  else {
    if(length(cut.points) == 0 | is.na(cut.points[1]) | cut.points[1] == 'All' | cut.points[1] == ''){
      cut.points <- c(-Inf, Inf)
    }
    else {
      cut.points <- cut.points[-1]
      cut.points <- cut.points[-length(cut.points)]
      cut.points <- c(-Inf, cut.points, Inf)
    }
    
    qf <- cut(coluna, cut.points, include.lowest = TRUE)
  }
  
  return(qf)
}

