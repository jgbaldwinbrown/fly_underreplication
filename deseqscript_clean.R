#!/usr/bin/env Rscript

#install.packages("htmltools")
#library(htmltools)
#source("https://bioconductor.org/biocLite.R")
#biocLite("DESeq2")

suppressMessages(suppressWarnings(library(data.table)))
suppressMessages(suppressWarnings(library("DESeq2")))
suppressMessages(suppressWarnings(library(ggplot2)))

minimal = function(countData) {
	metaData = as.data.frame(fread("metadata.txt"))
	# head(metaData)

	dds <- DESeqDataSetFromMatrix(countData=countData, 
				      colData=metaData, 
				      design=~hybridity, tidy = TRUE)
	dds <- DESeq(dds)
	res <- results(dds)
	# head(results(dds, tidy=TRUE)) #let's look at the results table
	# summary(res) #summary of results

	res <- res[order(res$padj),]
	# head(res)

	pdf("minimal_volcano.pdf", 4, 3)
	# par(mfrow=c(1,1))
	with(res, plot(log2FoldChange, -log10(pvalue), pch=20, main="Volcano plot", xlim=c(-3,3)))

	with(subset(res, padj<.01 ), points(log2FoldChange, -log10(pvalue), pch=20, col="blue"))
	with(subset(res, padj<.01 & abs(log2FoldChange)>2), points(log2FoldChange, -log10(pvalue), pch=20, col="red"))
	with(res[c("FBgn0051989", "FBgn0015391", "FBgn0027783", "FBgn0037831"),], points(log2FoldChange, -log10(pvalue), pch=20, col="green"))
	dev.off()

	#First we need to transform the raw count data
	#vst function will perform variance stabilizing transformation
	vsdata <- vst(dds, blind=FALSE)

	pdf("minimal_pca.pdf", 4, 3)
	print("plotting minimal pca")
	plotPCA(vsdata, intgroup="hybridity") #using the DESEQ2 plotPCA fxn we can
	print("plotted minimal pca")
	dev.off()
}

full = function(countData) {
	metaData = as.data.frame(fread("metadata.txt"))
	# head(metaData)

	dds <- DESeqDataSetFromMatrix(countData=countData, 
				      colData=metaData, 
				      design=~hybridity, tidy = TRUE)
	dds <- DESeq(dds)
	res <- results(dds)
	# head(results(dds, tidy=TRUE)) #let's look at the results table
	# summary(res) #summary of results

	res <- res[order(res$padj),]
	# head(res)

	pdf("full_volcano.pdf", 4, 3)
	# par(mfrow=c(1,1))
	with(res, plot(log2FoldChange, -log10(pvalue), pch=20, main="Volcano plot", xlim=c(-3,3)))

	with(subset(res, padj<.01 ), points(log2FoldChange, -log10(pvalue), pch=20, col="blue"))
	with(subset(res, padj<.01 & abs(log2FoldChange)>2), points(log2FoldChange, -log10(pvalue), pch=20, col="red"))
	with(res[c("FBgn0051989", "FBgn0015391", "FBgn0027783", "FBgn0037831"),], points(log2FoldChange, -log10(pvalue), pch=20, col="green"))
	dev.off()

	print(str(res))
	# print(res)
	# hits = res[abs(res$log2FoldChange)>2 & (-log10(res$padj) < .01),]
	# print(-log10(res$padj) < .01)
	hits0 = na.omit(res)
	hits1 = hits0[-log10(hits0$padj) < .01,]
	write.table(hits1, "hits1.txt", quote=FALSE, sep = "\t")
	hits2 = hits1[abs(hits1$log2FoldChange)>2,]
	write.table(hits2, "hits2.txt", quote=FALSE, sep = "\t")

	#First we need to transform the raw count data
	#vst function will perform variance stabilizing transformation
	vsdata <- vst(dds, blind=FALSE)

	pdf("full_pca.pdf", 4, 3)
	print("plotting full pca")
	plotPCA(vsdata, intgroup="hybridity") #using the DESEQ2 plotPCA fxn we can
	print("plotted full pca")
	dev.off()
}

minimal_rescue = function(countData) {
	countData = countData[,c("gene", "iso1_iso1", "ixa_female_iso1", "ixw_female_iso1", "ixl_female_iso1")]
	metaData = as.data.frame(fread("metadata_minimal_rescue.txt"))
	# head(metaData)

	dds <- DESeqDataSetFromMatrix(countData=countData, 
				      colData=metaData, 
				      design=~hybridity, tidy = TRUE)
	dds <- DESeq(dds)
	res <- results(dds)
	# head(results(dds, tidy=TRUE)) #let's look at the results table
	# summary(res) #summary of results

	res <- res[order(res$padj),]
	# head(res)

	pdf("minimal_rescue_volcano.pdf", 4, 3)
	# par(mfrow=c(1,1))
	with(res, plot(log2FoldChange, -log10(pvalue), pch=20, main="Volcano plot", xlim=c(-3,3)))

	with(subset(res, padj<.01 ), points(log2FoldChange, -log10(pvalue), pch=20, col="blue"))
	with(subset(res, padj<.01 & abs(log2FoldChange)>2), points(log2FoldChange, -log10(pvalue), pch=20, col="red"))
	with(res[c("FBgn0051989", "FBgn0015391", "FBgn0027783", "FBgn0037831"),], points(log2FoldChange, -log10(pvalue), pch=20, col="green"))
	dev.off()

	#First we need to transform the raw count data
	#vst function will perform variance stabilizing transformation
	vsdata <- vst(dds, blind=FALSE)

	pdf("minimal_rescue_pca.pdf", 4, 3)
	print("plotting minimal rescue pca")
	plotPCA(vsdata, intgroup="hybridity") #using the DESEQ2 plotPCA fxn we can
	print("plotted minimal rescue pca")
	dev.off()
}

main = function() {
	countData = as.data.frame(fread("combined.txt"))
	colnames(countData) = c("gene", "a4_iso1", "axw_female_iso1", "axw_male_iso1", "hxw_female_iso1", "hxw_male_iso1", "iso1_iso1", "ixa_female_iso1", "ixa_male_iso1", "ixl_female_iso1", "ixl_male_iso1", "ixw_female_iso1", "lhr_iso1", "ixw_male_iso1")

	minimal(countData)
	full(countData)
	minimal_rescue(countData)
}

main()
