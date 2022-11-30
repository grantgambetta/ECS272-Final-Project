<template>
    <div id="choropleth"></div>
</template>

<script>
import * as d3 from 'd3';
import { select } from 'd3-selection';
import { geomap } from 'd3-geomap';
import { json as d3JSONFetch } from 'd3-fetch';
// import { sankey, sankeyLinkHorizontal } from 'd3-sankey';
import dataMap from "../../assets/data/countries.json"
// import dataSankeyDetail from "../../assets/data/fire_sankey_detail.json"
// import dataSankeyDetailYear from "../../assets/data/fire_sankey_detailYear.json"
const path ='../../assets/data/countries.json';

export default {
  name: 'Choropleth',
  data() {
    return {

    };
  },
  props:{
    myMapData: Array,
  },
  mounted() {
    console.log('FIRST')
    console.log(dataMap);
    //let localData = dataSankey['data'];
    let localData = dataMap;
    //console.log(localData)
    // let localDataDetail=dataSankeyDetail["items"];
    // let localDataDetailYear=dataSankeyDetailYear["items"]; 
    this.drawChoropleth(localData, "#choropleth", path) 
    console.log("Data Passed down as a Prop  ", this.myMapData)
  },
  methods:{
    drawChoropleth(data, id,path) {
        const worldMap = geomap();
        const path1=require('../../assets/data/countries.json')
        worldMap.geoData(data);
        
        worldMap.draw(select(id));
        
        // dummy rectangles to select regions
        const svg = d3.select(id)
          .append("svg")
          .attr("width", 1000)
          .attr("height", 100);

        const rect = svg
          .append("rect")
          .attr("id","SouthAmerica")
          .attr("x", 0)
          .attr("y", 0)
          .attr("width", 400)
          .attr("height", 70)
          .text("South America")
          .attr("opacity",0.5)
          .attr("fill", "red")
          .on("click",(e,d,i) => {
            this.$emit("clicked",{'data':"SouthAmerica"})
          });

        rect
          .append("text")
          .attr("x", 0)
          .attr("y", 0)
          .attr("dy", ".35em")
          .attr("fill","black")
          .text("South America");


          const rect2 = svg
          .append("rect")
          .attr("id","MiddleEastNorthAfrica")
          .attr("x", 500)
          .attr("y", 0)
          .attr("width", 400)
          .attr("height", 70)
          .text("Middle east")
          .attr("opacity",0.5)
          .attr("fill", "blue")
          .on("click",(e,d,i) => {
            this.$emit("clicked",{'data':"MiddleEastNorthAfrica"})
          });



    }
  },
};
</script>