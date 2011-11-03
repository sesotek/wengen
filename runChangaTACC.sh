#!/bin/bash
#
# runChangaTACC.sh
# Author: Ian Smith
# Date: 2011/11/01
#
# Sets up all parameters for SGE and ChaNGa and executes within a timing script.
#
# Some variables can be passed from command line using:
#    qsub -v OUT_FILE="blah.out" netlinRunTACC.sh
#
# == Optional Variables to pass by qsub -v ==
# DOMAIN: Domain decomposition type. [0..3]
# BALANCER: Load balancer type. [OrbLB, Orb3dLB, GreedyLB, RefineLB, MultistepLB, ""], "" for none.
# PIECES: Total number of tree pieces. "Def" for default number chosen by ChaNGa (8 * cores)
# OUT_FILE: Output filename.
# PARAM_FILE: Parameter (.param) file to load.
# TEST_NAME: Name of this test.
# VERBOSITY: Changa option to -v
# LBDEBUG: Changa option to +LBDebug
# EXTRA_PARAM: Any extra parameter to add as a Changa option
#### The following boolean values are given a 0 or 1
# CONSPH: turn on consph?
# usage:
# ./runChangaTACC.sh <nodes> <ppn> <env vars to pass to qsub>


# Constants
JOBSCRIPT='runChangaScript'

# Create the file that will execute the job
EXECTMP='exectmp'$$

QSUB_ENV="${3}"
NUM_NODES="${1}"                         # Number of Nodes
PPN="${2}"	                            # Procs per node (TACC is 12-core nodes)
NUM_PROCS=$(( ${NUM_NODES} * ${PPN} ))	# Total number of procs

# Translate nodes and ppn variables so queue interprets them correctly
Q_PROCS_TO_RESERVE=$(( 12 * ${NUM_NODES} ))
Q_PEWAY="${PPN}way ${Q_PROCS_TO_RESERVE}"

# Queue Options:
#$ -cwd 		        # Start job in submission directory
#$ -N netlinRun         # Job Name
#$ -j y			        # Combine stderr and stdout
#$ -M imsmith@uw.edu    # Use email notification address
#$ -m be                # Email at Begin and End of job
#$ -q normal            # Queue name "normal"

#$ -l h_rt=24:00:00     # Run time (hh:mm:ss) - 4 hours
#$ -pe 8way 12          # eg: "-pe 12way 24" requests 12 tasks/node, 24 cores total
# --------------------

# Clear exectmp
echo > ${EXECTMP}
# Write shebang to exectmp
echo '#!/bin/bash' > ${EXECTMP}

# Write queue options to exectmp
echo '#$ -cwd' >> ${EXECTMP}
echo '#$ -N job' >> ${EXECTMP}
echo '#$ -q development' >> ${EXECTMP}
echo '#$ -l h_rt=1:00:00' >> ${EXECTMP}
echo '#$ -pe '${Q_PEWAY} >> ${EXECTMP}

# Append job script to run exectmp
cat ${JOBSCRIPT} >> ${EXECTMP}

# Call qsub with env vars and give it exectmp
QSUB_ENV="${QSUB_ENV}",NUM_NODES=${NUM_NODES},PPN=${PPN},NUM_PROCS=${NUM_PROCS}
echo "qsub -V -v ${QSUB_ENV}"
qsub -V -v "${QSUB_ENV}" ${EXECTMP}
