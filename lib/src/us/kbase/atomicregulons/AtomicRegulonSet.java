
package us.kbase.atomicregulons;

import java.util.HashMap;
import java.util.Map;
import javax.annotation.Generated;
import com.fasterxml.jackson.annotation.JsonAnyGetter;
import com.fasterxml.jackson.annotation.JsonAnySetter;
import com.fasterxml.jackson.annotation.JsonInclude;
import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.annotation.JsonPropertyOrder;


/**
 * <p>Original spec-file type: AtomicRegulonSet</p>
 * 
 * 
 */
@JsonInclude(JsonInclude.Include.NON_NULL)
@Generated("com.googlecode.jsonschema2pojo")
@JsonPropertyOrder({
    "expression_matrix_ref",
    "genome_ref",
    "expression_cutoff"
})
public class AtomicRegulonSet {

    @JsonProperty("expression_matrix_ref")
    private String expressionMatrixRef;
    @JsonProperty("genome_ref")
    private String genomeRef;
    @JsonProperty("expression_cutoff")
    private String expressionCutoff;
    private Map<String, Object> additionalProperties = new HashMap<String, Object>();

    @JsonProperty("expression_matrix_ref")
    public String getExpressionMatrixRef() {
        return expressionMatrixRef;
    }

    @JsonProperty("expression_matrix_ref")
    public void setExpressionMatrixRef(String expressionMatrixRef) {
        this.expressionMatrixRef = expressionMatrixRef;
    }

    public AtomicRegulonSet withExpressionMatrixRef(String expressionMatrixRef) {
        this.expressionMatrixRef = expressionMatrixRef;
        return this;
    }

    @JsonProperty("genome_ref")
    public String getGenomeRef() {
        return genomeRef;
    }

    @JsonProperty("genome_ref")
    public void setGenomeRef(String genomeRef) {
        this.genomeRef = genomeRef;
    }

    public AtomicRegulonSet withGenomeRef(String genomeRef) {
        this.genomeRef = genomeRef;
        return this;
    }

    @JsonProperty("expression_cutoff")
    public String getExpressionCutoff() {
        return expressionCutoff;
    }

    @JsonProperty("expression_cutoff")
    public void setExpressionCutoff(String expressionCutoff) {
        this.expressionCutoff = expressionCutoff;
    }

    public AtomicRegulonSet withExpressionCutoff(String expressionCutoff) {
        this.expressionCutoff = expressionCutoff;
        return this;
    }

    @JsonAnyGetter
    public Map<String, Object> getAdditionalProperties() {
        return this.additionalProperties;
    }

    @JsonAnySetter
    public void setAdditionalProperties(String name, Object value) {
        this.additionalProperties.put(name, value);
    }

    @Override
    public String toString() {
        return ((((((((("AtomicRegulonSet"+" [expressionMatrixRef=")+ expressionMatrixRef)+", genomeRef=")+ genomeRef)+", expressionCutoff=")+ expressionCutoff)+", additionalProperties=")+ additionalProperties)+"]");
    }

}
