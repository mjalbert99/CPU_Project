set out_dir "metals"
file mkdir ${out_dir}

write_lef ${out_dir}/${TOP}.lef

write_sdf ${out_dir}/${TOP}.sdf

