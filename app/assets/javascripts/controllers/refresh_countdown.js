(() => {
  stimulus.register("refresh-countdown", class extends Stimulus.Controller {
    
    connect() {
      // console.log( "refresh-countdown#connect()")
      
      this.load()
    
      if (this.data.has("interval")) {
        this.startCountdown()
      }
    }

    disconnect() {
      // console.log( "refresh-countdown#disconnect()")
      
      this.stopCountdown()
    }

    load() {
      // console.log( "refresh-countdown#load()")
      
      var i = parseInt(this.data.get("interval") )
      var now = new Date().getTime()
      var refreshAfter = now + (i * 1000)
            
      this.data.set( "secondsRemaining", i )
      this.data.set( "refreshAfter", refreshAfter )
    }
    
    cycle(){
      // console.log( "refresh-countdown#cycle()")
      var c = parseInt(this.data.get("secondsRemaining"))
      
      c = c - 1
      if (c == 0){
        this.refresh()
      }
      
      var d = new Date()
      var now = d.getTime()
      var refreshAfter = parseInt(this.data.get("refreshAfter"))
      
      //console.log( "time: " + d.getHours() + ":" + d.getMinutes() + ":" + d.getSeconds() )
      //console.log( "now: " + now )
      //console.log( "refreshAfter: " + refreshAfter )
      //console.log( "now - refreshAfter: " + (now - refreshAfter) )
      
      if (now > refreshAfter) {
        this.refresh()
      }
      
      var total = parseFloat( this.data.get("interval") )
      
      var percent = (total - c) / total
      
      // console.log( "Percent: " + percent )
      // console.log( "c: " + c )
      // console.log( "i: " + parseFloat( this.data.get("interval") ) )
      
      var circle = this.element.querySelector('circle');
      var radius = circle.r.baseVal.value;
      var circumference = radius * 2 * Math.PI;

      circle.style.strokeDasharray = `${circumference} ${circumference}`;
      circle.style.strokeDashoffset = `${circumference}`;

      const offset = circumference - percent * circumference;
      circle.style.strokeDashoffset = offset;
      
      this.data.set( "secondsRemaining", c )
      //this.element.innerText = c      
    }
    
    startCountdown() {
      // console.log( "refresh-countdown#startCycling()")
      
      this.stopCountdown()
      this.countdownTimer = setInterval(() => {
        this.cycle()
      }, 1000)
    }
    
    stopCountdown() {
      if (this.countdownTimer) {
        clearInterval(this.countdownTimer)
      }
    }
    
    refresh(){
      document.location.reload(true);
    }
    
  })
})() 