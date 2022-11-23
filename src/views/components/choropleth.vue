<template>
    <div id="choropleth"></div>
</template>

<script>
import * as d3 from 'd3';
import { select } from 'd3-selection';
import { geomap } from 'd3-geomap';
// import { sankey, sankeyLinkHorizontal } from 'd3-sankey';
import dataMap from "../../assets/data/countries.json"
// import dataSankeyDetail from "../../assets/data/fire_sankey_detail.json"
// import dataSankeyDetailYear from "../../assets/data/fire_sankey_detailYear.json"

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
    const path ='../../assets/data/countries.json';
    //console.log(localData)
    // let localDataDetail=dataSankeyDetail["items"];
    // let localDataDetailYear=dataSankeyDetailYear["items"]; 
    this.drawChoropleth(localData, "#choropleth", path) 
    console.log("Data Passed down as a Prop  ", this.myMapData)
  },
  methods:{
    drawChoropleth(data, id,path) {
        const worldMap = geomap();
        worldMap.geofile(path);
        
        worldMap.draw(select(id));
    }
  },
};
</script>