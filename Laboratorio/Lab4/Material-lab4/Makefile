.SUFFIXES: -seq -omp -tar
CC = icc

OPENMP	 = -fopenmp

TAREADORCC = tareador-clang
TAREADOR_FLAGS = -tareador-lite

CFLAGS  = -Wall -fno-inline -ffloat-store -std=c99
OPTG0   = -g -O0
OPT3    = -O3

CINCL   = -I. -I${FFTW3_HOME}/include
CLIBS   = -L. ${FFTW3_HOME}/lib/libfftw3f.a -lm

.c-seq: 
	$(CC) $(CFLAGS) $< -o $@ $(CLIBS) 

.c-tar:
	$(TAREADORCC) -D_TAREADOR_ $(CFLAGS) $(OPTG0) $(CINCL) $< -o $@ $(CLIBS) $(TAREADOR_FLAGS)

.c-omp: 
	$(CC) $(CFLAGS) $(OPENMP) $< -o $@ $(CLIBS) 

clean: 
	rm -rf *-seq *-omp *-tar

ultraclean:
	rm -rf logs *.log .tareador* TRACE*.mpit *.prv *.pcf *.row set-0 *.mpits *.sym *.o* *.e* time-* strong-* *.ps *.txt
