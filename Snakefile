r"""
This workflow automates the instructions given on https://energysystems-docs.netlify.app/tools/sector-coupled-euro-calliope-hands-on.html

To run, first download and unzip the pre-built models by running 

    snakemake --use-conda --profile default build

Then, to build an run a model, e.g.

    snakemake --use-conda --profile default "build/eurospores/inputs/2016_res_3h.nc"

Or, in general:

    snakemake --use-conda --profile default "build/<resolution>/inputs/run_<year>_<model_resolution>.nc"

With these wildcard options:
resolution: eurospores|ehighways
year: 2010 - 2018
model_resolution: res_2h|res_3h|res_6h
"""
wildcard_constraints:
    year = "2016|2017|2018",

# TODO: This rule can move to euro-calliope and become part of the switch between downloading/self-generating
rule download_pre_built:
    message: "Download and unzip prebuild"
    params: url="https://surfdrive.surf.nl/files/index.php/s/6TDxlPxkKR79sHy/download"
    output: directory("build/pre-built")
    shell: "curl -sLo '2022-02-08.zip' 'https://surfdrive.surf.nl/files/index.php/s/6TDxlPxkKR79sHy/download'; unzip '2022-02-08.zip'; mv 2022-02-08/* .; rm -r 2022-02-08; unzip 2050.zip -d build/pre-built; rm -r 2030.zip 2050.zip"


# TODO: this is another build phase, applying overrides
rule build_eurocalliope:
    #message: "Building Calliope {wildcards.resolution} model with {wildcards.model_resolution} hourly temporal resolution for the model year {wildcards.year}"
    input: model_yaml_path = "build/pre-built/model/{resolution}/model-{year}.yaml"
    params:
        scenario = "industry_fuel_shared,transport,heat,config_overrides,gas_storage,link_cap_dynamic,freeze-hydro-capacities,add-biofuel,synfuel_transmission,res_{model_resolution}h",
    output: "build/{resolution}/inputs/{year}_{model_resolution}.nc"
    # conda: "../envs/calliope.yaml"
    shell: "python create_input.py -i={input.model_yaml_path} -o {output} --scenario {params.scenario}"


rule run_eurocalliope:
    # message: "Running Calliope {wildcards.resolution} model with {wildcards.model_resolution} hourly temporal resolution for the model year {wildcards.year}"
    input: model = rules.build_eurocalliope.output[0]
    envmodules: "gurobi/9.0.2"
    output: "build/{resolution}/outputs/run_{year}_{model_resolution}.nc"
    # conda: "../envs/calliope.yaml"
    script: "run.py"