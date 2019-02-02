#!/bin/bash
### Directives pel gestor de cues
# following option makes sure the job will run in the current directory
#$ -cwd
# following option makes sure the job has the same environmnent variables as the submission shell
#$ -V
# Canviar el nom del job
#$ -N lab1-strong
# Per canviar de shell
#$ -S /bin/bash

USAGE="\n USAGE: ./submit-strong.sh prog\n
          prog -> openmp program name\n"

if (test $# -lt 1 || test $# -gt 1)
then
        echo -e $USAGE
        exit 0
fi

SEQ=$1-seq
PROG=$1-omp
size=13
cutoff=8
#Change this to cover your scalability study
np_NMIN=1
np_NMAX=12
N=3

# Make sure that all binaries exist
make $SEQ
make $PROG

out=/tmp/out.$$	    # Temporal file where you save the execution results
aux=/tmp/aux.$$     # archivo auxiliar

outputpath=./elapsed.txt
outputpath2=./speedup.txt
rm -rf $outputpath 2> /dev/null
rm -rf $outputpath2 2> /dev/null

echo Executing $SEQ sequentially
min_elapsed=1000  # Minimo del elapsed time de las N ejecuciones del programa
i=0        # Variable contador de repeticiones
while (test $i -lt $N)
	do
		echo -n Run $i... 
                /usr/bin/time --format=%e ./$SEQ -n$size -c$cutoff > $out 2>$aux

		time=`cat $aux|tail -n 1`
		echo Elapsed time = `cat $aux`
			
                st=`echo "$time < $min_elapsed" | bc`
                if [ $st -eq 1 ]; then
                   min_elapsed=$time
                fi
			
		rm -f $out
                rm -f $aux
		i=`expr $i + 1`
	done
echo -n ELAPSED TIME MIN OF $N EXECUTIONS =
sequential=`echo $min_elapsed`
echo $sequential
echo

echo "$PROG $size $np_NMIN $np_NMAX $N"

i=0
echo "Starting OpenMP executions..."

PARS=$np_NMIN
while (test $PARS -le $np_NMAX)
do
	echo Executing $PROG with $PARS threads 
        min_elapsed=1000  # Minimo del elapsed time de las N ejecuciones del programa

	while (test $i -lt $N)
		do
			echo -n Run $i... 
                        export OMP_NUM_THREADS=$PARS
                        /usr/bin/time --format=%e ./$PROG -n$size -c$cutoff > $out 2>$aux

			time=`cat $aux|tail -n 1`
			echo Elapsed time = `cat $aux`
			
                        st=`echo "$time < $min_elapsed" | bc`
                        if [ $st -eq 1 ]; then
                           min_elapsed=$time;
                        fi
			
			rm -f $out
                        rm -f $aux
			i=`expr $i + 1`
		done

	echo -n ELAPSED TIME MIN OF $N EXECUTIONS =

        min=`echo $min_elapsed`
    	result=`echo $sequential/$min|bc -l`
    	echo $min
	echo
	i=0

    	#output PARS i elapsed time minimo en fichero elapsed time
	echo -n $PARS >> $outputpath
	echo -n "   " >> $outputpath
    	echo $min >> $outputpath

    	#output PARS i speedup en fichero speedup
	echo -n $PARS >> $outputpath2
	echo -n "   " >> $outputpath2
    	echo $result >> $outputpath2

    	#incrementa el parametre
	PARS=`expr $PARS + 1`
done

echo "Resultat de l'experiment (tambe es troben a " $outputpath " i " $outputpath2 " )"
echo "#threads	Elapsed min"
cat $outputpath
echo
echo "#threads	Speedup"
cat $outputpath2
echo

HOST=$(echo $HOSTNAME | cut -f 1 -d'.')

jgraph -P strongscale.jgr >  strong-$PROG-$size-$np_NMIN-$np_NMAX-$N-${HOST}.ps