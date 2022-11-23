<template>
    <div class="row">
        <div class="column">
            <h1 class="chartTitle">Global Terrorism Attacks 1970-2017</h1>
            <div class="row" style="height: 50%">
                <h1 class="VisTitle">World Map to Select and visualize all data</h1>
                <Choropleth v-if="dataExists" :myMapData="myMapData"/>
            </div>
        </div>     
        <div class="column">
            <div class="row">
                <h1 class="VisTitle">Time series data</h1>
                <StackedArea v-if="dataExists" :myStackedAreaData="myStackedAreaData"/>
            </div>
        </div>
    </div>
    <div class="row">
        <h1 class="chartTitle">DETAILED VIEW</h1>
        <Sankey v-if="dataExists" :mySankeyData="mySankeyData" />
    </div>
</template>

<script>
// import BarChart from "../components/barchart.vue"
// import Scatter from "../components/scatter.vue"
import Sankey from "../components/sankey.vue"
import Choropleth from "../components/choropleth.vue"
import StackedArea from "../components/stackedArea.vue"
import * as d3 from "d3";
import csvPath from '../../assets/data/stackedArea.csv';

export default {
    data(){
        return {
            dataExists: false,
            myBarData: [],
            myScatterData: [],
            mySankeyData: [],
            myStackedAreaData: [], 
            myMapData: []
        }
    },
    components: {
        // BarChart,
        // Scatter,
        Sankey,
        StackedArea, 
        Choropleth
    },
    created(){
        /* Fetch via CSV */
        // this.drawBarFromCsv()
        this.drawScatterFromCsv()
    },
    mounted(){
        document.title="Global Terrorism";
    },
    methods: {
        drawScatterFromCsv(){
            //async method
            d3.csv(csvPath).then((data) => {
                // array of objects
                console.log(data.length);
                console.log(data);
                this.dataExists = true; // updates the v-if to conditionally show the barchart only if our data is here.
                // this.myBarData = data; // updates the prop value to be the recieved data, which we hand in to our bar-chart
                this.myStackedAreaData=data;
            });
        }
    }
}

</script>

<style>
    .chartTitle{
        font-size: 2em;
    }
    
    .VisTitle{
        font-size: 1.4em;
    }
    .note{
        font-size: 0.9em;
    }
    .button{
        font-size: 1.2em;
    }
    .column {
        float: left;
        width: 50%;
    }
    /* Clear floats after the columns */
    .row:after {
    content: "";
    display: table;
    clear: both;
    height: 50%;
    }
</style>
