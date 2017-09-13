#!/usr/bin/env Rscript
args = commandArgs(trailingOnly=TRUE)

if (length(args)!=4) {
  stop("Need four arguments .\n", call.=FALSE)
}

jacusa<-read.delim(args[1],as.is=T,header=F) #isoforms.fpkm_table
jacusa.site<-read.delim(args[2],as.is=T,header=F)

label1<-args[3];
label2<-args[4];

expandLab<-function(inp)
    {
        expand=unlist(strsplit(inp,split="_"));
        return(paste0(expand[1],1:expand[2]));
    }

#ENSG00000283189 3_49423655      1.1547777470490246
#ENSG00000283189 3_49423673      1.3504611229382135
#ENSG00000283189 3_49423692      1.1513838929852511

#1 182712 182712 A/C 1

library(biomaRt);
mart=useMart(biomart="ENSEMBL_MART_ENSEMBL", dataset="hsapiens_gene_ensembl", host="www.ensembl.org")
    resMArt=getBM(attributes=c("ensembl_gene_id","hgnc_symbol","description"),mart=mart)

require(openxlsx)

NamJac=c("Gene","Site","Score","Strand",expandLab(label1),expandLab(label2));
jacusa<-jacusa[,1:length(NamJac)]
colnames(jacusa)<-NamJac

NamSite=c("Site","Chr","Start","End","variant","Score","Strand",expandLab(label1),expandLab(label2));
jacusa.site<-jacusa.site[,1:length(NamSite)]
colnames(jacusa.site)<-NamSite

wb <- createWorkbook()
addWorksheet(wb, sheetName = "Full_report");

writeDataTable(wb, sheet = 1, x=merge(jacusa,resMArt, by.x=1, by.y=1))
addWorksheet(wb, sheetName = "Condensed_report");

SumScore=tapply(jacusa[,3],jacusa[,1],sum)
sites=tapply(jacusa[,2],jacusa[,1],paste,collapse=",")

jacusaCond=data.frame(ID=names(sites),Sites=sites,SumScore=as.numeric(SumScore));
jacusaCond=merge(jacusaCond, resMArt, by.x=1, by.y=1)
    
writeDataTable(wb, sheet = 2, x=data.frame(jacusaCond))

addWorksheet(wb, sheetName = "Site_report");
writeDataTable(wb, sheet = 3, x=data.frame(jacusa.site))

write.table(unique(data.frame(jacusa.site[,c("Chr","End","End")],ifelse(jacusa.site[,"Strand"]=="+","A/G","T/C"),1)),file= paste0(gsub(".txt","",args[2]),".vep"),quote=F,sep="\t",append=F, row.names=F, col.names=F)

saveWorkbook(wb, paste0(gsub(".txt","",args[1]),".xlsx"), overwrite=T)
