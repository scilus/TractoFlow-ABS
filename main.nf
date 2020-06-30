#!/usr/bin/env nextflow

params.root = false
params.help = false
params.dti_shells = false
params.fodf_shells = false

if(params.help) {
    usage = file("$baseDir/USAGE")

    cpu_count = Runtime.runtime.availableProcessors()
    bindings = ["b0_thr_extract_b0":"$params.b0_thr_extract_b0",
                "dwi_shell_tolerance":"$params.dwi_shell_tolerance",
                "dilate_b0_mask_prelim_brain_extraction":"$params.dilate_b0_mask_prelim_brain_extraction",
                "bet_prelim_f":"$params.bet_prelim_f",
                "run_dwi_denoising":"$params.run_dwi_denoising",
                "extent":"$params.extent",
                "run_topup":"$params.run_topup",
                "encoding_direction":"$params.encoding_direction",
                "readout":"$params.readout",
                "run_eddy":"$params.run_eddy",
                "eddy_cmd":"$params.eddy_cmd",
                "bet_topup_before_eddy_f":"$params.bet_topup_before_eddy_f",
                "use_slice_drop_correction":"$params.use_slice_drop_correction",
                "bet_dwi_final_f":"$params.bet_dwi_final_f",
                "fa_mask_threshold":"$params.fa_mask_threshold",
                "run_resample_dwi":"$params.run_resample_dwi",
                "dwi_resolution":"$params.dwi_resolution",
                "dwi_interpolation":"$params.dwi_interpolation",
                "run_t1_denoising":"$params.run_t1_denoising",
                "run_resample_t1":"$params.run_resample_t1",
                "t1_resolution":"$params.t1_resolution",
                "t1_interpolation":"$params.t1_interpolation",
                "number_of_tissues":"$params.number_of_tissues",
                "fa":"$params.fa",
                "min_fa":"$params.min_fa",
                "roi_radius":"$params.roi_radius",
                "set_frf":"$params.set_frf",
                "manual_frf":"$params.manual_frf",
                "mean_frf":"$params.mean_frf",
                "sh_order":"$params.sh_order",
                "basis":"$params.basis",
                "fodf_metrics_a_factor":"$params.fodf_metrics_a_factor",
                "relative_threshold":"$params.relative_threshold",
                "max_fa_in_ventricle":"$params.max_fa_in_ventricle",
                "min_md_in_ventricle":"$params.min_md_in_ventricle",
                "wm_seeding":"$params.wm_seeding",
                "algo":"$params.algo",
                "seeding":"$params.seeding",
                "nbr_seeds":"$params.nbr_seeds",
                "random":"$params.random",
                "step":"$params.step",
                "theta":"$params.theta",
                "min_len":"$params.min_len",
                "max_len":"$params.max_len",
                "compress_streamlines":"$params.compress_streamlines",
                "compress_value":"$params.compress_value",
                "cpu_count":"$cpu_count",
                "template_t1":"$params.template_t1",
                "processes_brain_extraction_t1":"$params.processes_brain_extraction_t1",
                "processes_denoise_dwi":"$params.processes_denoise_dwi",
                "processes_denoise_t1":"$params.processes_denoise_t1",
                "processes_eddy":"$params.processes_eddy",
                "processes_fodf":"$params.processes_fodf",
                "processes_registration":"$params.processes_registration"]

    engine = new groovy.text.SimpleTemplateEngine()
    template = engine.createTemplate(usage.text).make(bindings)

    print template.toString()
    return
}

log.info "TractoFlow-Aging pipeline"
log.info "========================="
log.info ""
log.info "Start time: $workflow.start"
log.info ""

log.debug "[Command-line]"
log.debug "$workflow.commandLine"
log.debug ""

log.info "[Git Info]"
log.info "$workflow.repository - $workflow.revision [$workflow.commitId]"
log.info ""

log.info "Options"
log.info "======="
log.info ""
log.info "[Denoise DWI]"
log.info "Denoise DWI: $params.run_dwi_denoising"
log.info ""
log.info "[Topup]"
log.info "Run Topup: $params.run_topup"
log.info ""
log.info "[Eddy]"
log.info "Run Eddy: $params.run_eddy"
log.info "Eddy command: $params.eddy_cmd"
log.info ""
log.info "[Resample DWI]"
log.info "Resample DWI: $params.run_resample_dwi"
log.info "Resolution: $params.dwi_resolution"
log.info ""
log.info "[DTI shells]"
log.info "DTI shells: $params.dti_shells"
log.info ""
log.info "[fODF shells]"
log.info "fODF shells: $params.fodf_shells"
log.info ""
log.info "[Compute fiber response function (FRF)]"
log.info "Set FRF: $params.set_frf"
log.info "FRF value: $params.manual_frf"
log.info ""
log.info "[Mean FRF]"
log.info "Mean FRF: $params.mean_frf"
log.info ""
log.info "[FODF Metrics]"
log.info "FODF basis: $params.basis"
log.info "SH order: $params.sh_order"
log.info ""
log.info "[Local tracking]"
log.info "Algo: $params.algo"
log.info "Seeding type: $params.seeding"
log.info "Number of seeds: $params.nbr_seeds"
log.info "Random seed: $params.random"
log.info "Step size: $params.step"
log.info "Theta: $params.theta"
log.info "Minimum length: $params.min_len"
log.info "Maximum length: $params.max_len"
log.info "FODF basis: $params.basis"
log.info "Compress streamlines: $params.compress_streamlines"
log.info "Compressing threshold: $params.compress_value"
log.info ""

log.info "Number of processes per tasks"
log.info "============================="
log.info "T1 brain extraction: $params.processes_brain_extraction_t1"
log.info "Denoise DWI: $params.processes_denoise_dwi"
log.info "Denoise T1: $params.processes_denoise_t1"
log.info "Eddy: $params.processes_eddy"
log.info "Compute fODF: $params.processes_fodf"
log.info "Registration: $params.processes_registration"
log.info ""

log.info "Template T1 path"
log.info "================"
log.info "Template T1: $params.template_t1"
log.info ""

workflow.onComplete {
    log.info "Pipeline completed at: $workflow.complete"
    log.info "Execution status: ${ workflow.success ? 'OK' : 'failed' }"
    log.info "Execution duration: $workflow.duration"
}

if (params.root){
    log.info "Input: $params.root"
    root = file(params.root)
    in_data = Channel
        .fromFilePairs("$root/**/*{aparc+aseg.nii.gz,bval,bvec,dwi.nii.gz,t1.nii.gz,wmparc.nii.gz}",
                       size: 6,
                       maxDepth:1,
                       flat: true) {it.parent.name}

    in_data
        .map{[it, params.readout, params.encoding_direction].flatten()}
        .into{in_data; check_subjects_number; lol}

    Channel
    .fromPath("$root/**/*rev_b0.nii.gz",
                    maxDepth:1)
    .map{[it.parent.name, it]}
    .into{rev_b0; check_rev_b0}
    }
else {
    error "Error ~ Please use --root for the input data."
}

if (!params.dti_shells || !params.fodf_shells){
    error "Error ~ Please set the DTI and fODF shells to use."
}

(dwi, gradients, t1_for_denoise, labels_for_reg, readout_encoding) = in_data
    .map{sid, aparc, bvals, bvecs, dwi, t1, wmparc, readout, encoding -> [tuple(sid, dwi),
                                        tuple(sid, bvals, bvecs),
                                        tuple(sid, t1),
                                        tuple(sid, aparc, wmparc),
                                        tuple(sid, readout, encoding)]}
    .separate(5)

check_rev_b0.count().into{ rev_b0_counter; number_rev_b0_for_compare }

check_subjects_number.count().into{ number_subj_for_null_check; number_subj_for_compare }

number_subj_for_null_check
.subscribe{a -> if (a == 0)
    error "Error ~ No subjects found. Please check the naming convention, your --root path or your BIDS folder."}

if (params.set_frf && params.mean_frf){
    error "Error ~ --set_frf and --mean_frf are activated. Please choose only one of these options. "
}

number_subj_for_compare
    .concat(number_rev_b0_for_compare)
    .toList()
    .subscribe{a, b -> if (a != b && b > 0)
    error "Error ~ Some subjects have a reversed phase encoded b=0 and others don't.\n" +
          "Please be sure to have the same acquisitions for all subjects."}

dwi.into{dwi_for_prelim_bet; dwi_for_denoise}

gradients
    .into{gradients_for_prelim_bet; gradients_for_eddy; gradients_for_topup;
          gradients_for_eddy_topup}

readout_encoding
    .into{readout_encoding_for_topup; readout_encoding_for_eddy;
          readout_encoding_for_eddy_topup}

dwi_for_prelim_bet
    .join(gradients_for_prelim_bet)
    .set{dwi_gradient_for_prelim_bet}

process README {
    cpus 1
    publishDir = params.Readme_Publish_Dir
    tag = "README"

    output:
    file "readme.txt"

    script:
    String list_options = new String();
    for (String item : params) {
        list_options += item + "\n"
    }
    """
    echo "TractoFlow pipeline\n" >> readme.txt
    echo "Start time: $workflow.start\n" >> readme.txt
    echo "[Command-line]\n$workflow.commandLine\n" >> readme.txt
    echo "[Git Info]\n" >> readme.txt
    echo "$workflow.repository - $workflow.revision [$workflow.commitId]\n" >> readme.txt
    echo "[Options]\n" >> readme.txt
    echo "$list_options" >> readme.txt
    """
}

process Bet_Prelim_DWI {
    cpus 2

    input:
    set sid, file(dwi), file(bval), file(bvec) from dwi_gradient_for_prelim_bet

    output:
    set sid, "${sid}__b0_bet_mask_dilated.nii.gz" into\
        b0_mask_for_eddy
    file "${sid}__b0_bet.nii.gz"
    file "${sid}__b0_bet_mask.nii.gz"

    script:
    """
    export ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=1
    export OMP_NUM_THREADS=1
    export OPENBLAS_NUM_THREADS=1
    scil_extract_b0.py $dwi $bval $bvec ${sid}__b0.nii.gz --mean\
        --b0_thr $params.b0_thr_extract_b0
    bet ${sid}__b0.nii.gz ${sid}__b0_bet.nii.gz -m -R -f $params.bet_prelim_f
    maskfilter ${sid}__b0_bet_mask.nii.gz dilate ${sid}__b0_bet_mask_dilated.nii.gz\
        --npass $params.dilate_b0_mask_prelim_brain_extraction -nthreads 1
    mrcalc ${sid}__b0.nii.gz ${sid}__b0_bet_mask_dilated.nii.gz\
        -mult ${sid}__b0_bet.nii.gz -quiet -force -nthreads 1
    """
}

process Denoise_DWI {
    cpus params.processes_denoise_dwi

    input:
    set sid, file(dwi) from dwi_for_denoise

    output:
    set sid, "${sid}__dwi_denoised.nii.gz" into\
        dwi_for_eddy,
        dwi_for_topup,
        dwi_for_eddy_topup

    script:
    // The denoised DWI is clipped to 0 since negative values
    // could have been introduced.
    if(params.run_dwi_denoising)
        """
        export ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=1
        export OMP_NUM_THREADS=1
        export OPENBLAS_NUM_THREADS=1
        dwidenoise $dwi dwi_denoised.nii.gz -extent $params.extent -nthreads $task.cpus
        fslmaths dwi_denoised.nii.gz -thr 0 ${sid}__dwi_denoised.nii.gz
        """
    else
        """
        mv $dwi ${sid}__dwi_denoised.nii.gz
        """
}

dwi_for_topup
    .join(gradients_for_topup)
    .join(rev_b0)
    .join(readout_encoding_for_topup)
    .set{dwi_gradients_rev_b0_for_topup}

process Topup {
    cpus 2

    input:
    set sid, file(dwi), file(bval), file(bvec), file(rev_b0), readout, encoding\
        from dwi_gradients_rev_b0_for_topup

    output:
    set sid, "${sid}__corrected_b0s.nii.gz", "${params.prefix_topup}_fieldcoef.nii.gz",
    "${params.prefix_topup}_movpar.txt" into topup_files_for_eddy_topup
    file "${sid}__rev_b0_warped.nii.gz"

    when:
    params.run_topup && params.run_eddy

    script:
    """
    export OMP_NUM_THREADS=$task.cpus
    export ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=1
    export OPENBLAS_NUM_THREADS=1
    scil_extract_b0.py $dwi $bval $bvec b0_mean.nii.gz --mean\
        --b0_thr $params.b0_thr_extract_b0
    antsRegistrationSyNQuick.sh -d 3 -f b0_mean.nii.gz -m $rev_b0 -o output -t r -e 1
    mv outputWarped.nii.gz ${sid}__rev_b0_warped.nii.gz
    scil_prepare_topup_command.py $dwi $bval $bvec ${sid}__rev_b0_warped.nii.gz\
        --config $params.config_topup --b0_thr $params.b0_thr_extract_b0\
        --encoding_direction $encoding\
        --readout $readout --out_prefix $params.prefix_topup\
        --out_script
    sh topup.sh
    cp corrected_b0s.nii.gz ${sid}__corrected_b0s.nii.gz
    """
}

dwi_for_eddy
    .join(gradients_for_eddy)
    .join(b0_mask_for_eddy)
    .join(readout_encoding_for_eddy)
    .set{dwi_gradients_mask_topup_files_for_eddy}

process Eddy {
    cpus params.processes_eddy

    input:
    set sid, file(dwi), file(bval), file(bvec), file(mask), readout, encoding\
        from dwi_gradients_mask_topup_files_for_eddy
    val(rev_b0_count) from rev_b0_counter

    output:
    set sid, "${sid}__dwi_corrected.nii.gz", "${sid}__bval_eddy",
        "${sid}__dwi_eddy_corrected.bvec" into\
        dwi_gradients_from_eddy
    set sid, "${sid}__dwi_corrected.nii.gz" into\
        dwi_from_eddy
    set sid, "${sid}__bval_eddy", "${sid}__dwi_eddy_corrected.bvec" into\
        gradients_from_eddy

    when:
    rev_b0_count == 0 || !params.run_topup || (!params.run_eddy && params.run_topup)

    // Corrected DWI is clipped to 0 since Eddy can introduce negative values.
    script:
    if (params.run_eddy) {
        slice_drop_flag=""
        if (params.use_slice_drop_correction) {
            slice_drop_flag="--slice_drop_correction"
        }
        """
        export OMP_NUM_THREADS=$task.cpus
        export ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=$task.cpus
        export OPENBLAS_NUM_THREADS=1
        scil_prepare_eddy_command.py $dwi $bval $bvec $mask\
            --eddy_cmd $params.eddy_cmd --b0_thr $params.b0_thr_extract_b0\
            --encoding_direction $encoding\
            --readout $readout --out_script --fix_seed\
            $slice_drop_flag
        sh eddy.sh
        fslmaths dwi_eddy_corrected.nii.gz -thr 0 ${sid}__dwi_corrected.nii.gz
        mv dwi_eddy_corrected.eddy_rotated_bvecs ${sid}__dwi_eddy_corrected.bvec
        mv $bval ${sid}__bval_eddy
        """
    }
    else {
        """
        mv $dwi ${sid}__dwi_corrected.nii.gz
        mv $bvec ${sid}__dwi_eddy_corrected.bvec
        mv $bval ${sid}__bval_eddy
        """
    }
}

dwi_for_eddy_topup
    .join(gradients_for_eddy_topup)
    .join(topup_files_for_eddy_topup)
    .join(readout_encoding_for_eddy_topup)
    .set{dwi_gradients_mask_topup_files_for_eddy_topup}

process Eddy_Topup {
    cpus params.processes_eddy

    input:
    set sid, file(dwi), file(bval), file(bvec), file(b0s_corrected),
        file(field), file(movpar), readout, encoding\
        from dwi_gradients_mask_topup_files_for_eddy_topup
    val(rev_b0_count) from rev_b0_counter

    output:
    set sid, "${sid}__dwi_corrected.nii.gz", "${sid}__bval_eddy",
        "${sid}__dwi_eddy_corrected.bvec" into\
        dwi_gradients_from_eddy_topup
    set sid, "${sid}__dwi_corrected.nii.gz" into\
        dwi_from_eddy_topup
    set sid, "${sid}__bval_eddy", "${sid}__dwi_eddy_corrected.bvec" into\
        gradients_from_eddy_topup
    file "${sid}__b0_bet_mask.nii.gz"

    when:
    rev_b0_count > 0 && params.run_topup

    // Corrected DWI is clipped to ensure there are no negative values
    // introduced by Eddy.
    script:
    if (params.run_eddy) {
        slice_drop_flag=""
        if (params.use_slice_drop_correction)
            slice_drop_flag="--slice_drop_correction"
        """
        export OMP_NUM_THREADS=$task.cpus
        export ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=$task.cpus
        export OPENBLAS_NUM_THREADS=1
        mrconvert $b0s_corrected b0_corrected.nii.gz -coord 3 0 -axes 0,1,2 -nthreads 1
        bet b0_corrected.nii.gz ${sid}__b0_bet.nii.gz -m -R\
            -f $params.bet_topup_before_eddy_f
        scil_prepare_eddy_command.py $dwi $bval $bvec ${sid}__b0_bet_mask.nii.gz\
            --topup $params.prefix_topup --eddy_cmd $params.eddy_cmd\
            --b0_thr $params.b0_thr_extract_b0\
            --encoding_direction $encoding\
            --readout $readout --out_script --fix_seed\
            $slice_drop_flag
        sh eddy.sh
        fslmaths dwi_eddy_corrected.nii.gz -thr 0 ${sid}__dwi_corrected.nii.gz
        mv dwi_eddy_corrected.eddy_rotated_bvecs ${sid}__dwi_eddy_corrected.bvec
        mv $bval ${sid}__bval_eddy
        """
    }
    else {
        """
        mv $dwi ${sid}__dwi_corrected.nii.gz
        mv $bvec ${sid}__dwi_eddy_corrected.bvec
        mv $bval ${sid}__bval_eddy
        """
    }
}

dwi_gradients_from_eddy
    .mix(dwi_gradients_from_eddy_topup)
    .set{dwi_gradients_for_extract_b0}

dwi_from_eddy
    .mix(dwi_from_eddy_topup)
    .set{dwi_for_bet}

gradients_from_eddy
    .mix(gradients_from_eddy_topup)
    .into{gradients_for_resample_b0;
          gradients_for_dti_shell;
          gradients_for_fodf_shell;
          gradients_for_normalize}

process Extract_B0 {
    cpus 2

    input:
    set sid, file(dwi), file(bval), file(bvec) from dwi_gradients_for_extract_b0

    output:
    set sid, "${sid}__b0.nii.gz" into b0_for_bet

    script:
    """
    export ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=1
    export OMP_NUM_THREADS=1
    export OPENBLAS_NUM_THREADS=1
    scil_extract_b0.py $dwi $bval $bvec ${sid}__b0.nii.gz --mean\
        --b0_thr $params.b0_thr_extract_b0
    """
}

dwi_for_bet
    .join(b0_for_bet)
    .set{dwi_b0_for_bet}

process Bet_DWI {
    cpus 2

    input:
    set sid, file(dwi), file(b0) from dwi_b0_for_bet

    output:
    set sid, "${sid}__b0_bet.nii.gz", "${sid}__b0_bet_mask.nii.gz" into\
        b0_and_mask_for_crop
    set sid, "${sid}__dwi_bet.nii.gz", "${sid}__b0_bet.nii.gz",
        "${sid}__b0_bet_mask.nii.gz" into dwi_b0_b0_mask_for_n4

    script:
    """
    export ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=1
    export OMP_NUM_THREADS=1
    export OPENBLAS_NUM_THREADS=1
    bet $b0 ${sid}__b0_bet.nii.gz -m -R -f $params.bet_dwi_final_f
    mrcalc $dwi ${sid}__b0_bet_mask.nii.gz -mult ${sid}__dwi_bet.nii.gz -quiet -nthreads 1
    """
}

process N4_DWI {
    cpus 1

    input:
    set sid, file(dwi), file(b0), file(b0_mask)\
        from dwi_b0_b0_mask_for_n4

    output:
    set sid, "${sid}__dwi_n4.nii.gz" into dwi_for_crop

    script:
    """
    export ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=$task.cpus
    export OMP_NUM_THREADS=1
    export OPENBLAS_NUM_THREADS=1
    N4BiasFieldCorrection -i $b0\
        -o [${sid}__b0_n4.nii.gz, bias_field_b0.nii.gz]\
        -c [300x150x75x50, 1e-6] -v 1
    scil_apply_bias_field_on_dwi.py $dwi bias_field_b0.nii.gz\
        ${sid}__dwi_n4.nii.gz --mask $b0_mask -f
    """
}

dwi_for_crop
    .join(b0_and_mask_for_crop)
    .set{dwi_and_b0_mask_b0_for_crop}

process Crop_DWI {
    cpus 1

    input:
    set sid, file(dwi), file(b0), file(b0_mask) from dwi_and_b0_mask_b0_for_crop

    output:
    set sid, "${sid}__dwi_cropped.nii.gz",
        "${sid}__b0_mask_cropped.nii.gz" into dwi_mask_for_normalize
    set sid, "${sid}__b0_mask_cropped.nii.gz" into mask_for_resample
    file "${sid}__b0_cropped.nii.gz"

    script:
    """
    export ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=1
    export OMP_NUM_THREADS=1
    export OPENBLAS_NUM_THREADS=1
    scil_crop_volume.py $dwi ${sid}__dwi_cropped.nii.gz -f\
        --output_bbox dwi_boundingBox.pkl -f
    scil_crop_volume.py $b0 ${sid}__b0_cropped.nii.gz\
        --input_bbox dwi_boundingBox.pkl -f
    scil_crop_volume.py $b0_mask ${sid}__b0_mask_cropped.nii.gz\
        --input_bbox dwi_boundingBox.pkl -f
    """
}

process Denoise_T1 {
    cpus params.processes_denoise_t1

    input:
    set sid, file(t1) from t1_for_denoise

    output:
    set sid, "${sid}__t1_denoised.nii.gz" into t1_for_n4

    script:
    if(params.run_t1_denoising)
        """
        export ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=1
        export OMP_NUM_THREADS=1
        export OPENBLAS_NUM_THREADS=1
        scil_run_nlmeans.py $t1 ${sid}__t1_denoised.nii.gz 1 \
            --processes $task.cpus -f
        """
    else
        """
        mv $t1 ${sid}__t1_denoised.nii.gz
        """
}

process N4_T1 {
    cpus 1

    input:
    set sid, file(t1) from t1_for_n4

    output:
    set sid, "${sid}__t1_n4.nii.gz" into t1_for_resample

    script:
    """
    export ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=$task.cpus
    export OMP_NUM_THREADS=1
    export OPENBLAS_NUM_THREADS=1
    N4BiasFieldCorrection -i $t1\
        -o [${sid}__t1_n4.nii.gz, bias_field_t1.nii.gz]\
        -c [300x150x75x50, 1e-6] -v 1
    """
}

process Resample_T1 {
    cpus 1

    input:
    set sid, file(t1) from t1_for_resample

    output:
    set sid, "${sid}__t1_resampled.nii.gz" into t1_for_bet

    script:
    if(params.run_resample_t1)
        """
        export ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=1
        export OMP_NUM_THREADS=1
        export OPENBLAS_NUM_THREADS=1
        scil_resample_volume.py $t1 ${sid}__t1_resampled.nii.gz \
            --resolution $params.t1_resolution \
            --interp  $params.t1_interpolation
        """
    else
        """
        mv $t1 ${sid}__t1_resampled.nii.gz
        """
}

process Bet_T1 {
    cpus params.processes_brain_extraction_t1

    input:
    set sid, file(t1) from t1_for_bet

    output:
    set sid, "${sid}__t1_bet.nii.gz", "${sid}__t1_bet_mask.nii.gz"\
        into t1_and_mask_for_crop

    script:
    """
    export ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=$task.cpus
    export OMP_NUM_THREADS=1
    export OPENBLAS_NUM_THREADS=1
    antsBrainExtraction.sh -d 3 -a $t1 -e $params.template_t1/t1_template.nii.gz\
        -o bet/ -m $params.template_t1/t1_brain_probability_map.nii.gz -u 0
    mrcalc $t1 bet/BrainExtractionMask.nii.gz -mult ${sid}__t1_bet.nii.gz -nthreads 1
    mv bet/BrainExtractionMask.nii.gz ${sid}__t1_bet_mask.nii.gz
    """
}

process Crop_T1 {
    cpus 1

    input:
    set sid, file(t1), file(t1_mask) from t1_and_mask_for_crop

    output:
    set sid, "${sid}__t1_bet_cropped.nii.gz", "${sid}__t1_bet_mask_cropped.nii.gz"\
        into t1_and_mask_for_reg

    script:
    """
    export ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=1
    export OMP_NUM_THREADS=1
    export OPENBLAS_NUM_THREADS=1
    scil_crop_volume.py $t1 ${sid}__t1_bet_cropped.nii.gz\
        --output_bbox t1_boundingBox.pkl -f
    scil_crop_volume.py $t1_mask ${sid}__t1_bet_mask_cropped.nii.gz\
        --input_bbox t1_boundingBox.pkl -f
    """
}


dwi_mask_for_normalize
    .join(gradients_for_normalize)
    .set{dwi_mask_grad_for_normalize}
process Normalize_DWI {
    cpus 3

    input:
    set sid, file(dwi), file(mask), file(bval), file(bvec) from dwi_mask_grad_for_normalize

    output:
    set sid, "${sid}__dwi_normalized.nii.gz" into dwi_for_resample
    file "${sid}_fa_wm_mask.nii.gz"

    script:
    """
    export ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=1
    export OMP_NUM_THREADS=1
    export OPENBLAS_NUM_THREADS=1
    scil_extract_dwi_shell.py $dwi \
        $bval $bvec $params.dti_shells dwi_dti.nii.gz \
        bval_dti bvec_dti -t $params.dwi_shell_tolerance
    scil_compute_dti_metrics.py dwi_dti.nii.gz bval_dti bvec_dti --mask $mask\
        --not_all --fa fa.nii.gz
    mrthreshold fa.nii.gz ${sid}_fa_wm_mask.nii.gz -abs $params.fa_mask_threshold -nthreads 1
    dwinormalise $dwi ${sid}_fa_wm_mask.nii.gz ${sid}__dwi_normalized.nii.gz\
        -fslgrad $bvec $bval -nthreads 1
    """
}

dwi_for_resample
    .join(mask_for_resample)
    .set{dwi_mask_for_resample}
process Resample_DWI {
    cpus 3

    input:
    set sid, file(dwi), file(mask) from dwi_mask_for_resample

    output:
    set sid, "${sid}__dwi_resampled.nii.gz" into\
        dwi_for_resample_b0,
        dwi_for_extract_dti_shell,
        dwi_for_extract_fodf_shell

    script:
    if (params.run_resample_dwi)
        """
        export ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=1
        export OMP_NUM_THREADS=1
        export OPENBLAS_NUM_THREADS=1
        scil_resample_volume.py $dwi \
            dwi_resample.nii.gz \
            --resolution $params.dwi_resolution \
            --interp  $params.dwi_interpolation
        fslmaths dwi_resample.nii.gz -thr 0 dwi_resample_clipped.nii.gz
        scil_resample_volume.py $mask \
            mask_resample.nii.gz \
            --ref dwi_resample.nii.gz \
            --enforce_dimensions \
            --interp nn
        mrcalc dwi_resample_clipped.nii.gz mask_resample.nii.gz\
            -mult ${sid}__dwi_resampled.nii.gz -quiet -nthreads 1
        """
    else
        """
        mv $dwi ${sid}__dwi_resampled.nii.gz
        """
}

dwi_for_resample_b0
    .join(gradients_for_resample_b0)
    .set{dwi_and_grad_for_resample_b0}

process Resample_B0 {
    cpus 3

    input:
    set sid, file(dwi), file(bval), file(bvec) from dwi_and_grad_for_resample_b0

    output:
    set sid, "${sid}__b0_resampled.nii.gz" into b0_for_reg
    set sid, "${sid}__b0_mask_resampled.nii.gz" into\
        b0_mask_for_dti_metrics,
        b0_mask_for_fodf,
        b0_mask_for_rf

    script:
    """
    export ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=1
    export OMP_NUM_THREADS=1
    export OPENBLAS_NUM_THREADS=1
    scil_extract_b0.py $dwi $bval $bvec ${sid}__b0_resampled.nii.gz --mean\
        --b0_thr $params.b0_thr_extract_b0
    mrthreshold ${sid}__b0_resampled.nii.gz ${sid}__b0_mask_resampled.nii.gz\
        --abs 0.00001 -nthreads 1
    """
}

dwi_for_extract_dti_shell
    .join(gradients_for_dti_shell)
    .set{dwi_and_grad_for_extract_dti_shell}

process Extract_DTI_Shell {
    cpus 3

    input:
    set sid, file(dwi), file(bval), file(bvec)\
        from dwi_and_grad_for_extract_dti_shell

    output:
    set sid, "${sid}__dwi_dti.nii.gz", "${sid}__bval_dti",
        "${sid}__bvec_dti" into \
        dwi_and_grad_for_dti_metrics, \
        dwi_and_grad_for_rf

    script:
    """
    export ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=1
    export OMP_NUM_THREADS=1
    export OPENBLAS_NUM_THREADS=1
    scil_extract_dwi_shell.py $dwi \
        $bval $bvec $params.dti_shells ${sid}__dwi_dti.nii.gz \
        ${sid}__bval_dti ${sid}__bvec_dti -t $params.dwi_shell_tolerance -f
    """
}

dwi_and_grad_for_dti_metrics
    .join(b0_mask_for_dti_metrics)
    .set{dwi_and_grad_for_dti_metrics}

process DTI_Metrics {
    cpus 3

    input:
    set sid, file(dwi), file(bval), file(bvec), file(b0_mask)\
        from dwi_and_grad_for_dti_metrics

    output:
    file "${sid}__ad.nii.gz"
    file "${sid}__evecs.nii.gz"
    file "${sid}__evecs_v1.nii.gz"
    file "${sid}__evecs_v2.nii.gz"
    file "${sid}__evecs_v3.nii.gz"
    file "${sid}__evals.nii.gz"
    file "${sid}__evals_e1.nii.gz"
    file "${sid}__evals_e2.nii.gz"
    file "${sid}__evals_e3.nii.gz"
    file "${sid}__fa.nii.gz"
    file "${sid}__ga.nii.gz"
    file "${sid}__rgb.nii.gz"
    file "${sid}__md.nii.gz"
    file "${sid}__mode.nii.gz"
    file "${sid}__norm.nii.gz"
    file "${sid}__rd.nii.gz"
    file "${sid}__tensor.nii.gz"
    file "${sid}__nonphysical.nii.gz"
    file "${sid}__pulsation_std_dwi.nii.gz"
    file "${sid}__residual.nii.gz"
    file "${sid}__residual_iqr_residuals.npy"
    file "${sid}__residual_mean_residuals.npy"
    file "${sid}__residual_q1_residuals.npy"
    file "${sid}__residual_q3_residuals.npy"
    file "${sid}__residual_residuals_stats.png"
    file "${sid}__residual_std_residuals.npy"
    set sid, "${sid}__fa.nii.gz", "${sid}__md.nii.gz" into fa_md_for_fodf
    set sid, "${sid}__fa.nii.gz" into\
        fa_for_reg

    script:
    """
    export ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=1
    export OMP_NUM_THREADS=1
    export OPENBLAS_NUM_THREADS=1
    scil_compute_dti_metrics.py $dwi $bval $bvec --mask $b0_mask\
        --ad ${sid}__ad.nii.gz --evecs ${sid}__evecs.nii.gz\
        --evals ${sid}__evals.nii.gz --fa ${sid}__fa.nii.gz\
        --ga ${sid}__ga.nii.gz --rgb ${sid}__rgb.nii.gz\
        --md ${sid}__md.nii.gz --mode ${sid}__mode.nii.gz\
        --norm ${sid}__norm.nii.gz --rd ${sid}__rd.nii.gz\
        --tensor ${sid}__tensor.nii.gz\
        --non-physical ${sid}__nonphysical.nii.gz\
        --pulsation ${sid}__pulsation.nii.gz\
        --residual ${sid}__residual.nii.gz\
        -f
    """
}

dwi_for_extract_fodf_shell
    .join(gradients_for_fodf_shell)
    .set{dwi_and_grad_for_extract_fodf_shell}

process Extract_FODF_Shell {
    cpus 3

    input:
    set sid, file(dwi), file(bval), file(bvec)\
        from dwi_and_grad_for_extract_fodf_shell

    output:
    set sid, "${sid}__dwi_fodf.nii.gz", "${sid}__bval_fodf",
        "${sid}__bvec_fodf" into\
        dwi_and_grad_for_fodf

    script:
    """
    export ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=1
    export OMP_NUM_THREADS=1
    export OPENBLAS_NUM_THREADS=1
    scil_extract_dwi_shell.py $dwi \
        $bval $bvec $params.fodf_shells ${sid}__dwi_fodf.nii.gz \
        ${sid}__bval_fodf ${sid}__bvec_fodf -t $params.dwi_shell_tolerance -f
    """
}

t1_and_mask_for_reg
    .join(labels_for_reg)
    .join(fa_for_reg)
    .join(b0_for_reg)
    .set{t1_labels_fa_b0_for_reg}

process Register_T1 {
    cpus params.processes_registration

    input:
    set sid, file(t1), file(t1_mask), file(aparc), file(wmparc), file(fa), file(b0) from t1_labels_fa_b0_for_reg

    output:
    file "${sid}__t1_warped.nii.gz"
    file "${sid}__output0GenericAffine.mat"
    file "${sid}__output1InverseWarp.nii.gz"
    file "${sid}__output1Warp.nii.gz"
    file "${sid}__t1_mask_warped.nii.gz"
    set sid, "${sid}__aparc_warped.nii.gz", "${sid}__wmparc_warped.nii.gz" \
        into labels_for_segmentation

    script:
    """
    export ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=$task.cpus
    export OMP_NUM_THREADS=1
    export OPENBLAS_NUM_THREADS=1
    antsRegistration --dimensionality 3 --float 0\
        --output [output,outputWarped.nii.gz,outputInverseWarped.nii.gz]\
        --interpolation Linear --use-histogram-matching 0\
        --winsorize-image-intensities [0.005,0.995]\
        --initial-moving-transform [$b0,$t1,1]\
        --transform Rigid['0.2']\
        --metric MI[$b0,$t1,1,32,Regular,0.25]\
        --convergence [500x250x125x50,1e-6,10] --shrink-factors 8x4x2x1\
        --smoothing-sigmas 3x2x1x0\
        --transform Affine['0.2']\
        --metric MI[$b0,$t1,1,32,Regular,0.25]\
        --convergence [500x250x125x50,1e-6,10] --shrink-factors 8x4x2x1\
        --smoothing-sigmas 3x2x1x0\
        --transform SyN[0.1,3,0]\
        --metric MI[$b0,$t1,1,32]\
        --metric CC[$fa,$t1,1,4]\
        --convergence [50x25x10,1e-6,10] --shrink-factors 4x2x1\
        --smoothing-sigmas 3x2x1
    mv outputWarped.nii.gz ${sid}__t1_warped.nii.gz
    mv output0GenericAffine.mat ${sid}__output0GenericAffine.mat
    mv output1InverseWarp.nii.gz ${sid}__output1InverseWarp.nii.gz
    mv output1Warp.nii.gz ${sid}__output1Warp.nii.gz
    antsApplyTransforms -d 3 -i $t1_mask -r ${sid}__t1_warped.nii.gz \
        -o ${sid}__t1_mask_warped.nii.gz -n NearestNeighbor \
        -t ${sid}__output1Warp.nii.gz ${sid}__output0GenericAffine.mat
    antsApplyTransforms -d 3 -i $aparc -r ${sid}__t1_warped.nii.gz \
        -o ${sid}__aparc_warped.nii.gz -n NearestNeighbor \
        -t ${sid}__output1Warp.nii.gz ${sid}__output0GenericAffine.mat
    antsApplyTransforms -d 3 -i $wmparc -r ${sid}__t1_warped.nii.gz \
        -o ${sid}__wmparc_warped.nii.gz -n NearestNeighbor \
        -t ${sid}__output1Warp.nii.gz ${sid}__output0GenericAffine.mat
    """
}

process Segment_Tissues {
    cpus 1

    input:
    set sid, file(aparc), file(wmparc) from labels_for_segmentation

    output:
    set sid, "${sid}__mask_wm_bin.nii.gz", "${sid}__mask_nuclei_bin.nii.gz" \
        into mask_wm_nuclei_for_tracking_mask
    file "${sid}__mask_cortex_bin.nii.gz"
    file "${sid}__mask_csf_1_bin.nii.gz"
    file "${sid}__merged_tissues.nii.gz"

    script:
    """
    export ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=1
    export OMP_NUM_THREADS=1
    export OPENBLAS_NUM_THREADS=1
    mkdir wmparc_desikan/
    mkdir wmparc_subcortical/
    mkdir aparc+aseg_desikan/
    mkdir aparc+aseg_subcortical/
    mrconvert $aparc aparc+aseg_int16.nii.gz -datatype int16 -force -nthreads 1
    mrconvert $wmparc wmparc_int16.nii.gz -datatype int16 -force -nthreads 1
    cd wmparc_desikan/
    scil_split_volume_by_labels.py ../wmparc_int16.nii.gz --scilpy_lut freesurfer_desikan_killiany
    cd ../
    cd wmparc_subcortical/
    scil_split_volume_by_labels.py ../wmparc_int16.nii.gz --scilpy_lut freesurfer_subcortical
    cd ../
    cd aparc+aseg_desikan/
    scil_split_volume_by_labels.py ../aparc+aseg_int16.nii.gz --scilpy_lut freesurfer_desikan_killiany
    cd ../
    cd aparc+aseg_subcortical/
    scil_split_volume_by_labels.py ../aparc+aseg_int16.nii.gz --scilpy_lut freesurfer_subcortical
    cd ../
    scil_image_math.py union wmparc_desikan/* wmparc_subcortical/right-cerebellum-cortex.nii.gz wmparc_subcortical/left-cerebellum-cortex.nii.gz mask_cortex_m.nii.gz -f
    scil_image_math.py union wmparc_subcortical/corpus-callosum-* aparc+aseg_subcortical/*white-matter* wmparc_subcortical/brain-stem.nii.gz aparc+aseg_subcortical/*ventraldc* mask_wm_m.nii.gz -f
    scil_image_math.py union wmparc_subcortical/*thalamus* wmparc_subcortical/*putamen* wmparc_subcortical/*pallidum* wmparc_subcortical/*hippocampus* wmparc_subcortical/*caudate* wmparc_subcortical/*amygdala* wmparc_subcortical/*accumbens* wmparc_subcortical/*plexus* mask_nuclei_m.nii.gz -f
    scil_image_math.py union wmparc_subcortical/*-lateral-ventricle.nii.gz wmparc_subcortical/*-inferior-lateral-ventricle.nii.gz wmparc_subcortical/cerebrospinal-fluid.nii.gz wmparc_subcortical/*th-ventricle.nii.gz mask_csf_1_m.nii.gz -f

    mrthreshold mask_wm_m.nii.gz ${sid}__mask_wm_bin.nii.gz -abs 0.1 -force -nthreads 1
    mrthreshold mask_cortex_m.nii.gz ${sid}__mask_cortex_bin.nii.gz -abs 0.1 -force -nthreads 1
    mrthreshold mask_nuclei_m.nii.gz ${sid}__mask_nuclei_bin.nii.gz -abs 0.1 -force -nthreads 1
    mrthreshold mask_csf_1_m.nii.gz ${sid}__mask_csf_1_bin.nii.gz -abs 0.1 -force -nthreads 1

    mrcalc ${sid}__mask_wm_bin.nii.gz 1 -mult mask_wm.nii.gz -nthreads 1
    mrcalc ${sid}__mask_cortex_bin.nii.gz 2 -mult mask_gm.nii.gz -nthreads 1
    mrcalc ${sid}__mask_nuclei_bin.nii.gz 3 -mult mask_nuclei.nii.gz -nthreads 1
    mrcalc ${sid}__mask_csf_1_bin.nii.gz 4 -mult mask_csf_1.nii.gz -nthreads 1
    mrcalc mask_wm.nii.gz mask_gm.nii.gz -add mask_nuclei.nii.gz -add mask_csf_1.nii.gz -add ${sid}__merged_tissues.nii.gz -nthreads 1
    """
}

dwi_and_grad_for_rf
    .join(b0_mask_for_rf)
    .set{dwi_b0_for_rf}

process Compute_FRF {
    cpus 3

    input:
    set sid, file(dwi), file(bval), file(bvec), file(b0_mask)\
        from dwi_b0_for_rf

    output:
    set sid, "${sid}__frf.txt" into unique_frf, unique_frf_for_mean
    file "${sid}__frf.txt" into all_frf_to_collect

    script:
    if (params.set_frf)
        """
        export ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=1
        export OMP_NUM_THREADS=1
        export OPENBLAS_NUM_THREADS=1
        scil_compute_ssst_frf.py $dwi $bval $bvec frf.txt --mask $b0_mask\
        --fa $params.fa --min_fa $params.min_fa --min_nvox $params.min_nvox\
        --roi_radius $params.roi_radius
        scil_set_response_function.py frf.txt $params.manual_frf ${sid}__frf.txt
        """
    else
        """
        export ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=1
        export OMP_NUM_THREADS=1
        export OPENBLAS_NUM_THREADS=1
        scil_compute_ssst_frf.py $dwi $bval $bvec ${sid}__frf.txt --mask $b0_mask\
        --fa $params.fa --min_fa $params.min_fa --min_nvox $params.min_nvox\
        --roi_radius $params.roi_radius
        """
}

all_frf_to_collect
    .collect()
    .set{all_frf_for_mean_frf}

process Mean_FRF {
    cpus 1
    publishDir = params.Mean_FRF_Publish_Dir
    tag = {"All_FRF"}

    input:
    file(all_frf) from all_frf_for_mean_frf

    output:
    file "mean_frf.txt" into mean_frf

    when:
    params.mean_frf && !params.set_frf

    script:
    """
    export ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=1
    export OMP_NUM_THREADS=1
    export OPENBLAS_NUM_THREADS=1
    scil_compute_mean_frf.py $all_frf mean_frf.txt
    """
}

frf_for_fodf = unique_frf

if (params.mean_frf) {
    frf_for_fodf = unique_frf_for_mean
                   .merge(mean_frf)
                   .map{it -> [it[0], it[2]]}
}

dwi_and_grad_for_fodf
    .join(b0_mask_for_fodf)
    .join(fa_md_for_fodf)
    .join(frf_for_fodf)
    .set{dwi_b0_metrics_frf_for_fodf}

process FODF_Metrics {
    cpus params.processes_fodf

    input:
    set sid, file(dwi), file(bval), file(bvec), file(b0_mask), file(fa),
        file(md), file(frf) from dwi_b0_metrics_frf_for_fodf

    output:
    set sid, "${sid}__fodf.nii.gz" into fodf_for_tracking
    file "${sid}__peaks.nii.gz"
    file "${sid}__peak_indices.nii.gz"
    file "${sid}__afd_max.nii.gz"
    file "${sid}__afd_total.nii.gz"
    file "${sid}__afd_sum.nii.gz"
    file "${sid}__nufo.nii.gz"

    script:
    """
    export ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=1
    export OMP_NUM_THREADS=1
    export OPENBLAS_NUM_THREADS=1
    scil_compute_fodf.py $dwi $bval $bvec $frf --sh_order $params.sh_order\
        --sh_basis $params.basis --force_b0_threshold --mask $b0_mask\
        --fodf ${sid}__fodf.nii.gz --peaks ${sid}__peaks.nii.gz\
        --peak_indices ${sid}__peak_indices.nii.gz --processes $task.cpus

    scil_compute_fodf_max_in_ventricles.py ${sid}__fodf.nii.gz $fa $md\
        --max_value_output ventricles_fodf_max_value.txt --sh_basis $params.basis\
        --fa_t $params.max_fa_in_ventricle --md_t $params.min_md_in_ventricle\
        -f

    a_threshold=\$(echo $params.fodf_metrics_a_factor*\$(cat ventricles_fodf_max_value.txt)|bc)

    scil_compute_fodf_metrics.py ${sid}__fodf.nii.gz \${a_threshold}\
        --mask $b0_mask --sh_basis $params.basis --afd ${sid}__afd_max.nii.gz\
        --afd_total ${sid}__afd_total.nii.gz --afd_sum ${sid}__afd_sum.nii.gz\
        --nufo ${sid}__nufo.nii.gz --rt $params.relative_threshold -f
    """
}

process Tracking_Mask {
    cpus 1

    input:
    set sid, file(wm), file(nuclei) from mask_wm_nuclei_for_tracking_mask

    output:
    set sid, "${sid}__tracking_mask.nii.gz",
        "${sid}__seeding_mask.nii.gz" into tracking_masks_for_tracking

    script:
    """
    export ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=1
    export OMP_NUM_THREADS=1
    export OPENBLAS_NUM_THREADS=1
    mrcalc $wm $nuclei -add ${sid}__tracking_mask.nii.gz -nthreads 1
    cp ${sid}__tracking_mask.nii.gz ${sid}__seeding_mask.nii.gz
    """
}

fodf_for_tracking
    .join(tracking_masks_for_tracking)
    .set{fodf_masks_for_tracking}

process Local_Tracking {
    cpus 2

    input:
    set sid, file(fodf), file(tracking_mask), file(seed)\
        from fodf_masks_for_tracking

    output:
    file "${sid}__tracking.trk"

    script:
    compress =\
        params.compress_streamlines ? '--compress ' + params.compress_value : ''
        """
        export ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=1
        export OMP_NUM_THREADS=1
        export OPENBLAS_NUM_THREADS=1
        scil_compute_local_tracking.py $fodf $seed $tracking_mask\
            ${sid}__tracking.trk --algo $params.algo\
            --$params.seeding $params.nbr_seeds --seed $params.random\
            --step $params.step --theta $params.theta\
            --min_len $params.min_len --max_len $params.max_len\
            --sh_basis $params.basis $compress
        """
}
