'''

    Hua Sun
    2021-01-30

    Merage all of gene-level to one file
    
    // *.geneLevel.from_seg.cn
    Sample   Chromosome      Start   End     Gene    Segment_Mean    Call

    INPUT
    /path/dir

    OUTPUT
    `merged.geneLevel.from_seg.hg38.log2ratio.tsv`
    e.g.
    Gene Sample1 Sample2 ...

    python3 mergeMultipleFilesToOne.py ./gatk4scna

'''

import os
import sys
import pandas as pd


dir = sys.argv[1]
cmd = f'cat {dir}/*/*.geneLevel.from_seg.cn | grep -v Segment_Mean > {dir}/merged.geneLevel.cn.tmp'
os.system(cmd)

df = pd.read_csv(f'{dir}/merged.geneLevel.cn.tmp', sep='\t', header=None)
df.columns = ['Sample','Chromosome','Start','End','Gene','Segment_Mean','Call']

df_spread = df.pivot_table(values='Segment_Mean', index=['Gene'], columns='Sample', aggfunc='first')
df_spread = df_spread.reset_index()

df_spread.to_csv(f'{dir}/merged.geneLevel.from_seg.hg38.log2ratio.tsv', sep='\t', index=False)
os.remove(f'{dir}/merged.geneLevel.cn.tmp')


