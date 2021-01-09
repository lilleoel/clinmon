# ==== DOCUMENTATION ====

#' Hemodynamic Indexes Calculated From Clinical Monitoring (clinmon)
#'
#' `clinmon()` uses a *continuous* recording and returns a dataframe with hemodynamic indexes for every period, epoch or block depending on the chosen output. Includes `COest`, `CVRi`, `Dx`, `Mx`, `PI`, `PRx`, `PWA`, `RI`, and `Sx` (see details).
#'
#' @name clinmon
#'
#' @usage clinmon(df, variables,
#' trigger = NULL, deleter = NULL,
#' blocksize = 3, epochsize = 20,
#' overlapping = FALSE, freq = 1000,
#' blockmin = 0.5, epochmin = 0.5,
#' output = "period", fast = FALSE)
#'
#' @param df Raw continuous recording with all numeric data and first column has to be time in seconds. (`dataframe`)
#'
#' @param variables Defining the type and order of the recorded variables as a list. Middle cerebral artery blood velocity (`'mcav'`) Arterial blood pressure (`'abp'`), cerebral perfusion pressure (`'cpp'`), intracranial pressure (`'icp'`), and heart rate (`'hr'`) is currently supported. (`list`)
#'
#' @param trigger Trigger with two columns: (1) start and (2) end of period to be analysed. Every row is a period for analysis. Default is `NULL`. (`dataframe`)
#'
#' @param deleter Deleter with two columns: (1) start and (2) end of period with artefacts which need to be deleted. Every row is a period with artefacts. Default is `NULL`. (`dataframe`)
#'
#' @param blocksize Length of a block, in seconds. Default is `3`. (`numeric`)
#'
#' @param epochsize Size of epochs, in number of blocks. Default is `20`. (`numeric`)
#'
#' @param overlapping The number of block which should overlap when calculating correlation based indexes, and remain blank if overlapping calculations should not be utilized. Default is `FALSE`. (`numeric`)
#'
#' @param freq Frequency of recorded data, in Hz. Default is `1000`. (`numeric`)
#'
#' @param blockmin Minimum measurements required to create a block in ratio. Default is `0.5` corresponding to 50%. (`numeric`)
#'
#' @param epochmin Minimum blocks required to create an epoch in ratio. Default is `0.5` corresponding to 50%. (`numeric`)
#'
#' @param output Select what the rows should represent in the output. Correlation based indexes are not presented when selecting blocks for every row. Currently `'block'`, `'epoch'`, or `'period'` is supported. Default is `'period'`. (`string`)
#'
#' @param fast Select if you want the data to aggregated resulting in a faster, but perhabs more imprecise run, in Hz. Default is `FALSE.` (`numeric`)
#'
#' @details
#'
#' Using a *continuous* raw recording, this `clinmon()` calculates hemodynamic indexes for every period, epoch or block depending on the chosen output.
#'
#' ```
#' head(data)
#' ```
#' | `time` | `abp` | `mcav` |
#' | --: | --: | --: |
#' | `7.00` | `78` | `45` |
#' | `7.01` | `78` | `46` |
#' | `...` | `...` | `...` |
#' | `301.82` | `82` | `70` |
#' | `301.83` | `81` | `69` |
#'
#' To calculate the indexes insert the data and select the relevant variables.
#'
#' ```
#' clinmon(df=data, variables=c("abp","mcav"))
#' ```
#' See **Value** for output description.
#'
#' @return Returns a dataframe with the results, with either
#' every blocks, epochs or periods as rows, depending on the chosen output.
#'
#' | **Column**         | **Description** |
#' | ---                | --- |
#' | `period`           | The period number corresponding to the row-number in the trigger file. |
#' | `epoch`            | The epoch number, or if `period` is chosen as output it reflects the number of epochs in the period. |
#' | `block`            | The block number, or if `period` or `epoch` is chosen as output it reflects the number of blocks in the `period` or `epoch`. |
#' | `time_min`         | The mimimum time value or the `period`, `epoch` or `block`. |
#' | `time_max`         | The maximum time value or the `period`, `epoch` or `block`. |
#' | `missing_percent`  | The percentage of missing data in the `period`, `epoch` or `block`. |
#' | `*_mean`           | The mean value of each variable for the `period`, `epoch` or `block`. |
#' | `*_min`            | The minimum value of each variable for the `period`, `epoch` or `block`. |
#' | `*_max`            | The maximum value of each variable for the `period`, `epoch` or `block`. |
#' | `*`                | The indexes in each column. |
#'
#' @section Hemodynamic indexes:
#' ## Estimated cardiac output (`COest`)
#' *Required variables:* `abp`, `hr`; *Required output:* `-`.
#'
#' Estimated cardiac output (`COest`) is calculated by utilizing the method described by Koenig et al. \[1]:
#'    \deqn{COest = PP / (SBP+DBP) * HR}
#' PP: Pulse pressure; SBP: systolic blood pressure; DBP: diastolic blood pressure; HR: heart rate.
#'
#' ## Cardiovascular resistance index (`CVRi`)
#' *Required variables:* `abp`, `mcav`; *Required output:* `-`.
#'
#' Cardiovascular resistance index (`CVRi`) is calculated utilizing the method described by Fan et al. \[2]:
#'    \deqn{CVRi = mean ABP / mean MCAv }
#' ABP: arterial blood pressure; MCAv: middle cerebral artery blood velocity.
#'
#' ## Diastolic flow index (`Dx`)
#' *Required variables:* `cpp`, `abp`, `mcav`; *Required output:* `epoch`, `period`.
#'
#' Diastolic flow index (`Dx`) is calculated utilizing the method described by Reinhard et al. \[3]:
#'    \deqn{Dx = cor( mean CPP / min MCAv ) }
#'    \deqn{Dxa = cor( mean ABP / min MCAv ) }
#' cor: correlation coefficient; CPP: cerebral perfusion pressure; ABP: arterial blood pressure; MCAv: middle cerebral artery blood velocity.
#'
#' ## Mean flow index (`Mx`)
#' *Required variables:* `cpp`, `abp`, `mcav`; *Required output:* `epoch`, `period`.
#'
#' Mean flow index (`Mx`) is calculated utilizing the method described by Czosnyka et al. \[4]:
#'    \deqn{Mx = cor( mean CPP / mean MCAv ) }
#'    \deqn{Mxa = cor( mean ABP / mean MCAv ) }
#' cor: correlation coefficient; CPP: cerebral perfusion pressure; ABP: arterial blood pressure; MCAv: middle cerebral artery blood velocity.
#'
#' ## Gosling index of pulsatility  (`PI`)
#' *Required variables:* `mcav`; *Required output:* `-`.
#'
#' Gosling index of pulsatility (`PI`) is calculated utilizing the method described by Michel et al. \[5]:
#'    \deqn{PI = (systolic MCAv - diastolic MCAv) / mean MCAv  }
#' MCAv: middle cerebral artery blood velocity.
#'
#' ## Pressure reactivity index (`PRx`)
#' *Required variables:* `cpp`, `icp`; *Required output:* `epoch`, `period`.
#'
#' Pressure reactivity index (`PRx`) is calculated utilizing the method described by Czosnyka et al. \[6]:
#'    \deqn{PRx = cor( mean CPP / mean ICP ) }
#' cor: correlation coefficient; CPP: cerebral perfusion pressure; ICP: intracranial pressure.
#'
#' ## Pulse wave amplitude (`PWA`)
#' *Required variables:* `cpp`, `icp`, `abp`, `mcav`; *Required output:* `-`.
#'
#' Pulse wave amplitude (`PWA`) is calculated utilizing the method described by Norager et al. \[7]:
#'    \deqn{PWA = systolic - diastolic }
#'
#' ## Pourcelot’s resistive (resistance) index (`RI`)
#' *Required variables:* `mcav`; *Required output:* `-`.
#'
#' Pourcelot’s resistive (resistance) index (`RI`) is calculated utilizing the method described by Forster et al. \[8]:
#'    \deqn{RI = (systolic MCAv - diastolic MCAv) / systolic MCAv  }
#' MCAv: middle cerebral artery blood velocity.
#'
#' ## Systolic flow index (`Sx`)
#' *Required variables:* `cpp`, `abp`, `mcav`; *Required output:* `epoch`, `period`.
#'
#' Systolic flow index (`Sx`) is calculated utilizing the method described by Czosnyka et al. \[4]:
#'    \deqn{Sx = cor( mean CPP / systolic MCAv ) }
#'    \deqn{Sxa = cor( mean ABP / systolic MCAv ) }
#' cor: correlation coefficient; CPP: cerebral perfusion pressure; ABP: arterial blood pressure; MCAv: middle cerebral artery blood velocity.
#'
#' @references
#' 1. Koenig et al. (2015) Biomed Sci Instrum. 2015;51:85-90. (\href{https://pubmed.ncbi.nlm.nih.gov/25996703/}{PubMed})
#' 2. Fan et al. (2018) Front Physiol. 2018 Jul 16;9:869. (\href{https://pubmed.ncbi.nlm.nih.gov/30061839/}{PubMed})
#' 3. Reinhard et al. (2003) Stroke. 2003 Sep;34(9):2138-44. (\href{https://pubmed.ncbi.nlm.nih.gov/12920261/}{PubMed})
#' 4. Czosnyka et al. (1996) Stroke. 1996 Oct;27(10):1829-34. (\href{https://pubmed.ncbi.nlm.nih.gov/8841340/}{PubMed})
#' 5. Michel et al. (1998) Ultrasound Med Biol. 1998 May;24(4):597-9. (\href{https://pubmed.ncbi.nlm.nih.gov/9651969/}{PubMed})
#' 6. Czosnyka et al. (1997) Neurosurgery. 1997 Jul;41(1):11-7; discussion 17-9. (\href{https://pubmed.ncbi.nlm.nih.gov/9218290/}{PubMed})
#' 7. Norager et al. (2020) Acta Neurochir (Wien). 2020 Dec;162(12):2983-2989. (\href{https://pubmed.ncbi.nlm.nih.gov/32886224/}{PubMed})
#' 8. Forster et al. (2017) J Paediatr Child Health. 2018 Jan;54(1):61-68. (\href{https://pubmed.ncbi.nlm.nih.gov/28845537/}{PubMed})
#'
#'
#' @examples
#' df <- data.frame(seq(1, 901, 0.01),
#'          rnorm(90001), rnorm(90001))
#' clinmon(df, variables=c("abp","mcav"), freq=100)
#'
#' @export
#
# ==== FUNCTION ====

globalVariables(c("block","epoch","n","period","overlapping"))

clinmon <- function(
   #Dataframes
   df, variables,
   trigger = NULL, deleter = NULL,
   #Calculation settings
   blocksize = 3, epochsize = 20,
   overlapping = FALSE, freq = 1000,
   #Data Quality
   blockmin = 0.5, epochmin = 0.5,
   #Output
   output = "period", fast = FALSE
){
   colnames(df) <- c("t",variables)

   #OPTIMIZE
   df <- Z.fast(df,freq,fast)
   freq <- Z.fast_ftf(freq,fast)

   #DATA MANAGEMENT
   df <- Z.datamanagement(df, variables, trigger, deleter, blocksize, freq)
   df.block <- Z.aggregate(df, variables, blocksize, epochsize,
                           overlapping, freq, blockmin, epochmin)

   #ANALYSES (variables = abp,mcav,hr,icp,cpp)
   df.block <- Z.block_analyses(df.block,variables)
   df.epoch <- Z.epoch_analyses(df.block,variables,overlapping)

   #OUTPUT
   df.output <- Z.output(df.block,df.epoch,output,overlapping)

   return(df.output)
}