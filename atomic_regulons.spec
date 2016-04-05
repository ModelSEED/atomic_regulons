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
   
   
   typedef structure {
       string expression_matrix_ref;
       string genome_ref;
   } AtomicRegulonSet;
   
   funcdef compute_atomic_regulons(workspace_name, expression_matrix_ref, genome_ref) returns (AtomicRegulonSet) authentication required;

};