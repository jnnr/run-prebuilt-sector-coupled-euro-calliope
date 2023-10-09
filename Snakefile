LOGS = "logs/"
wildcard_constraints:
    year = "2016|2017|2018",

# TODO: This rule can move to euro-calliope and become part of the switch between downloading/self-generating
rule download_pre_built:
    message: "Download and unzip prebuild"
    params: url="https://surfdrive.surf.nl/files/index.php/s/6TDxlPxkKR79sHy/download"
    output: directory("build/pre-built")
    shell: "curl -sLo '2022-02-08.zip' 'https://surfdrive.surf.nl/files/index.php/s/6TDxlPxkKR79sHy/download'; unzip '2022-02-08.zip'; rm -r 2022-02-08.zip; mv 2022-02-08/* .; rm -r 2022-02-08; unzip 2050.zip -d {output}; rm -r 2030.zip 2050.zip"


# TODO: this is another build phase, applying overrides
rule build_eurocalliope:
    #message: "Building Calliope {wildcards.resolution} model with {wildcards.model_resolution} hourly temporal resolution for the model year {wildcards.year}"
    conda: "requirements_custom.yml"
    input:
        prebuild = "build/pre-built",
        script="create_input_custom.py",
    params:
        model_yaml_path = "model/{resolution}/model-{year}.yaml",
        # scenario according to https://energysystems-docs.netlify.app/tools/sector-coupled-euro-calliope-hands-on.html
        scenario = "industry_fuel,transport,heat,config_overrides,gas_storage,link_cap_dynamic,freeze-hydro-capacities,add-biofuel,synfuel_transmission,{model_resolution}",
    output: "build/{resolution}/inputs/{year}_{model_resolution}.nc"
    log: LOGS + "build_eurocalliope_{resolution}_{year}_{model_resolution}.log"
    # conda: "../envs/calliope.yaml"
    shell: "python {input.script} -i {input.prebuild}/{params.model_yaml_path} -o {output} --scenario {params.scenario} 2> {log}"

rule run_eurocalliope:
    # message: "Running Calliope {wildcards.resolution} model with {wildcards.model_resolution} hourly temporal resolution for the model year {wildcards.year}"
    conda: "requirements_custom.yml"
    input:
        model = rules.build_eurocalliope.output[0],
        script = "run_custom.py"
    envmodules: "gurobi/9.0.2"
    output: "build/{resolution}/outputs/{year}_{model_resolution}.nc"
    log: LOGS + "run_eurocalliope_{resolution}_{year}_{model_resolution}.log"
    # conda: "../envs/calliope.yaml"
    shell: "python {input.script} -i {input.model} -o {output} 2> {log} 1> {log}"
