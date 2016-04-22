/*
A KBase module: atomic_regulons
This sample module contains one small method - filter_contigs.
*/

module atomic_regulons {
    /*
       A string representing the workspace name
   */
   typedef string workspace_name;
   /*
       String represent the Expression Matrix
   */
   typedef string expression_matrix_ref;
   /*
       A string for the genome
   */
   typedef string genome_ref;
   /*
       A string for the expression_cutoff
   */
   typedef string expression_cutoff;

   /*
       A string for the output regulon set
   */
   typedef string output_atomicRegulons;

   typedef structure {
       string expression_matrix_ref;
       string genome_ref;
       string expression_cutoff;
   } AtomicRegulonSet;

   funcdef compute_atomic_regulons(workspace_name, genome_ref, expression_matrix_ref, expression_cutoff, output_atomicRegulons) returns (AtomicRegulonSet) authentication required;

};
