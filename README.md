# MARA
Pacote do R que reúne diversas funções utilitárias de aplicação geral no projeto MARA da DIE.

* **Versão**: 1.0
* **Data**: 05 de Maio de 2016
* **Autor**: Ricardo S. Carvalho (ricardosc@gmail.com)
* **Licença**: GNU General Public License, version 2

--------------

**Para instalar pacote**:
```
install.packages("devtools")
library(devtools)

install_github("ricardoscr/MARA")
```

**Para iniciar uso e ver documentação**:
```
library(MARA)

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
