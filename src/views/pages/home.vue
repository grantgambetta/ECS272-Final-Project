<template>
    <div class="row">
        <div class="column">
            <h1 class="chartTitle">Global Terrorism Attacks 1970-2017</h1>
            <div class="row" style="height: 50%">
                <h1 class="VisTitle">World Map to Select and visualize all data</h1>
                <Choropleth v-if="dataExists" :myMapData="myMapData" @clicked="handleClickRegion"/>
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
        <Sankey v-if="dataExists" :mySankeyData="mySankeyData" :regionString="regionString" />
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

import dataSankey from "../../assets/data/sankey/SouthAmerica_count_attacks.json"
import jsonPath from "../../assets/data/sankey/MiddleEastNorthAfrica_count_attacks.json";
import dataSankeyME from "../../assets/data/sankey/MiddleEastNorthAfrica_count_attacks.json"


export default {
    data(){
        return {
            dataExists: true,
            myBarData: [],
            myScatterData: [],
            mySankeyData: dataSankey["items"],
            regionString: "SouthAmerica",
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
            console.log("To do: ",data);
            switch(data.data){
                case "MiddleEastNorthAfrica":
                    console.log("succes");
                    this.regionString="MiddleEastNorthAfrica";
                    // this.mySankeyData=dataSankeyME['items'];
                    this.mySankeyData = {
                    ...dataSankeyME['items'],
                    };
                    // const path1=require("../../assets/data/sankey/MiddleEastNorthAfrica_count_attacks.json")
                    // d3.json(dataSankeyME).then((dataX) => {
                    //     this.mySankeyData=dataX['items'];
                    // });
                    break;
                case "SouthAmerica":
                    console.log("failure or south");
                    this.regionString="SouthAmerica";
                    this.mySankeyData=dataSankey['items'];          
                    break;
            } 
        },
        // drawSankeyAgain(xyz){
        //     // console.log(Sankey)
        //     // this.mySankeyData=dataSankeyME['items']
        //     // this.Sankey.methods.drawSankey(dataSankeyME, "#sankey","MiddleEastNorthAfrica") 

        // }
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
