(() => {
  stimulus.register("image-set", class extends Stimulus.Controller {
    
    connect() {
      console.log( "image-set#connect()")
      
      this.load()
    
      if (this.data.has("cycleInterval")) {
        this.startCycling()
      }
    }

    disconnect() {
      console.log( "image-set#disconnect()")
      
      this.stopCycling()
    }

    load() {
      console.log( "image-set#load()")
      
      
      var images = this.element.querySelectorAll('img')
      
      var n = 0
      images.forEach(function(element) {
        element.setAttribute( "data-index", n )
        n = n + 1
      })
      
      this.data.set( "index", 0 )
      this.data.set( "lastIndex", n - 1 )
      
    }
    
    cycle(){
      console.log( "image-set#cycle()")
      var index = parseInt(this.data.get("index"))
      
      var images = this.element.querySelectorAll('img')
      images.forEach(function(element) {
        if (index == parseInt( element.getAttribute( "data-index" ) ) ){
          element.classList.add( 'active' )
        }else{
          element.classList.remove( 'active' )
        }
      })
      
      if ( index < parseInt( this.data.get( "lastIndex" ) ) ){
        index += 1
      }else{
        index = 0
      }
      
      this.data.set( "index", index )
    }
    
    startCycling() {
      this.stopCycling()
      this.cycleTimer = setInterval(() => {
        this.cycle()
      }, this.data.get("cycleInterval"))
    }
    
    stopCycling() {
      if (this.cycleTimer) {
        clearInterval(this.cycleTimer)
      }
    }
    
  })
})()