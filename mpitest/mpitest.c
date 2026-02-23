#include <mpi.h>
#include <stdio.h>
#include <assert.h>

int main( int argc, char *argv[])
{
  int myrank = -1, nranks = -1, len = 0;
  char version[MPI_MAX_LIBRARY_VERSION_STRING];
  int provided;
//  MPI_Init(&argc,&argv);
  MPI_Init_thread(&argc,&argv,MPI_THREAD_MULTIPLE, &provided);
  MPI_Comm_rank(MPI_COMM_WORLD, &myrank); MPI_Comm_size(MPI_COMM_WORLD, &nranks);
  if (myrank == 0) {
    printf("%d\n", nranks);
    MPI_Get_library_version(version, &len);
    printf("%s\n", version);
  }

  int buffer_sent = 12345, received = -1;
  if (myrank == 0) {
    MPI_Request request;
    printf("MPI process %d sends value %d.\n", myrank, buffer_sent);
    MPI_Isend(&buffer_sent, 1, MPI_INT, 1, 0, MPI_COMM_WORLD, &request);
    MPI_Wait(&request, MPI_STATUS_IGNORE);
  }
  else if (myrank == 1) {
    MPI_Request request;
    MPI_Irecv(&received, 1, MPI_INT, 0, 0, MPI_COMM_WORLD, &request);
    MPI_Wait(&request, MPI_STATUS_IGNORE);
    printf("MPI process %d received value: %d.\n", myrank, received);
    assert(buffer_sent==received);
  }

  MPI_Finalize();
  return 0;
}
