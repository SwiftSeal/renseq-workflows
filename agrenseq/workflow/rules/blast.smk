rule blast_db:
    input:
        subject = config["blast_genome"]
    output:
        temp(multiext("results/blast/blast", ".ndb", ".nhr", ".nin", ".njs", ".not", ".nsq", ".ntf", ".nto"))
    conda:
        "../envs/blast.yaml"
    resources:
        mem_mb = 1000
    log:
        "logs/blast_db/makeblastdb.log"
    shell:
        """
        makeblastdb -in {input.subject} -dbtype nucl -out "results/blast/blast" 2> {log}
        """

rule run_blast:
    input:
        get_reference,
        multiext("results/blast/blast", ".ndb", ".nhr", ".nin", ".njs", ".not", ".nsq", ".ntf", ".nto")
    output:
        blast_result = "results/blast/{reference}_blast_sorted.txt",
    threads:
        8
    conda:
        "../envs/blast.yaml"
    resources:
        mem_mb = 4000,
        slurm_partition = "medium"
    log:
        "logs/run_blast/{reference}.log"
    shell:
        """
        blastn -query {input[0]} -db "results/blast/blast" -outfmt 6 -num_threads {threads} | sort -k1,1 -k12,12nr -k11,11n | sort -u -k1,1 --merge 1> {output.blast_result} 2> {log}
        """
