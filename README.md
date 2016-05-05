# MARA
Pacote do R que reúne diversas funções utilitárias de aplicação geral no projeto MARA da DIE.

* **Versão**: 1.0
* **Data**: 05 de Maio de 2016
* **Autor**: Ricardo S. Carvalho (ricardosc@gmail.com)
* **Licença**: GNU General Public License, version 2

--------------

### Para instalar pacote
```
# Instalar pré-requisitos
install.packages("RODBC")
install.packages("dummies")
install.packages("stringr")
install.packages("devtools")

# Instalar MARA
library(devtools)
install_github("ricardoscr/MARA")
library(MARA)
```

### Funções e documentação
As funções da versão atual podem ter a documentação correspondente acessada como segue.
```
## Funções de Bancos de Dados
?instrucoes.MySQL
?instrucoes.SQLServer
?runSQLonDB
?insertDataIntoDB

## Funções de pré-processamento
?limpaCaracteres
?discretizaComCutPoints
?getDFcomDummyCols
```

### Uso das funções de Bancos de Dados
Deve-se criar um arquivo de nome **database_logins.txt** e mantê-lo no Working Directory (setado com setwd). Tal arquivo deve conter os nomes dos data sources, usuários e senhas para conexões com SGBDs.
Um exemplo do conteúdo de tal arquivo é:
```
servHomologDDD
usuarioFulano
senhaDoFulano

servDesenvABC
usuarioCicrano
senhaDoCicrano
```
Recomenda-se manter tal arquivo localmente, cada usuário com seu grupo de logins/data sources, sem compartilhamento.
