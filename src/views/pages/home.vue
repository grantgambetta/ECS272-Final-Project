<template>
    <div class="row">
        <div class="column">
            <h1 class="chartTitle" style = "position: absolute; top: 65px;">Global Terrorism Activities 1970-2017</h1>
            <div class="row1">
                <h1 class="VisTitle" style = "position: absolute; top: 120px; left: 170px;">World Map to Select a Country/Region</h1>
                <Choropleth v-if="dataExists" :myMapData="myMapData" :regionString="regionString" @clicked="handleClickRegion"/>

            </div>
        </div>     
        <div class="column">
            <div class="row">
                <h1 class="VisTitle" style = "position: absolute; left: 1350px; top: 110px;">Evolution over time</h1>
                <StackedArea v-if="dataExists" :myStackedAreaData="myStackedAreaData" :regionString="regionString"/>
            </div>
        </div>
    </div>
    <div class="row" style = "position: absolute; left: 850px; top: 70px;">
        <!--h1 class="chartTitle">DETAILED VIEW</h1-->
        <label class="button" >
            Choose Metric to show:     
        </label>
        <select id="metric" @change="handleMetricChange">
            <option value="count_attacks">Number of Attacks</option>
            <option value="kills">People killed</option>
            <option value="wounded">People injured</option>
        </select>
        <br>
        <Sankey v-if="dataExists" :mySankeyData="mySankeyData" :regionString="regionString" />
    </div>
    <h1 style = "position: absolute; left: 40px; top: 580px;">Summary Statistics</h1>
    <div id="summary_stats" style = "position: absolute; top: 600px; left: 40px; height: 400; width: 400;"></div>
</template>

<script>
// import BarChart from "../components/barchart.vue"
// import Scatter from "../components/scatter.vue"


import Sankey from "../components/sankey.vue"
import Choropleth from "../components/choropleth.vue"
import StackedArea from "../components/stackedArea.vue"
import * as d3 from "d3";
import csvPath from '../../assets/data/stackedArea.csv';

import dataStackedArea from "../../assets/data/timeSeries/world_count_attacks.json"
import dataSankey from "../../assets/data/sankey/world_count_attacks.json"


export default {
    data(){
        return {
            dataExists: true,
            myBarData: [],
            myScatterData: dataStackedArea['data'],
            mySankeyData: dataSankey["items"],
            regionString: "world",
            metricString: "count_attacks",
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
        // this.drawSankey()
    },
    mounted(){
        document.title="Global Terrorism";
    },
    methods: {
        drawSankey(){
            //async method
            // d3.csv(csvPath).then((data) => {
            // dataSankey["items"].then((data) => {
                // array of objects
                // console.log(data.length);
                // console.log(data);
                // this.dataExists = true; // updates the v-if to conditionally show the barchart only if our data is here.
                // this.myBarData = data; // updates the prop value to be the recieved data, which we hand in to our bar-chart
                // this.mySankeyData=data;
            // });
        },
        handleClickRegion(data){
            console.log("Update region: ",data);
            // update selected region
            this.regionString=data.data;    
            // update data for sankey, require reads the json
            this.mySankeyData=require("../../assets/data/sankey/"+this.regionString+"_"+this.metricString+".json")['items'];
            // update time series
            this.myStackedAreaData=require("../../assets/data/timeSeries/"+this.regionString+"_"+this.metricString+".json")['data'];
        },
        handleMetricChange(data){
            console.log("Update metric: ",d3.select('#metric').property("value"));
            
            // update selected metric
            this.metricString=d3.select('#metric').property("value");  
            this.regionString="world";   
            // update data for sankey, require reads the json
            this.mySankeyData=require("../../assets/data/sankey/"+this.regionString+"_"+this.metricString+".json")['items'];
            
            // update time series
            this.myStackedAreaData=require("../../assets/data/timeSeries/"+this.regionString+"_"+this.metricString+".json")['data'];
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
    .columnMap{
        float: left;
        width: 75%;
    }
    /* Clear floats after the columns */
    .row:after {
    content: "";
    display: table;
    clear: both;
    height: 50%;
    }
</style>
