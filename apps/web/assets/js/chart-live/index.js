const DatasetChart = {
  mounted() {
    // let chartEl = this.el.parentElement.querySelector(".chart");
    // let size = chartEl.getBoundingClientRect();
    // let options = Object.assign({}, chartEl.dataset, {
    //   tagged: (chartEl.dataset.tags && chartEl.dataset.tags !== "") || false,
    //   width: size.width,
    //   height: 300,
    //   now: new Date().getTime() / 1000,
    // });
    // this.chart = new TelemetryChart(chartEl, options);

    const data = Array.from(this.el.children || []).map((val) => {
      let label = val.dataset.label;
      let data = Array.from(val.children || []).map(({ dataset: { x, y } }) => {
        return { x: parseFloat(x), y: parseFloat(y) };
      });
      return { label, data };
    });
    console.log(data);
  }, //,
  //   updated() {
  //     const data = Array.from(this.el.children || []).map(
  //       ({ dataset: { x, y, z } }) => {
  //         return { x, y: parseFloat(y), z: parseInt(z) };
  //       }
  //     );

  //     if (data.length > 0) {
  //       this.chart.pushData(data);
  //     }
  //   },
};

export default DatasetChart;
