(function () {
  return {
customConfig:
                
`
    <style>

        #myMain{
            margin: 15px 0 0 15px
        }
        
        #phone_value2{
            width: 150px; 
            height: 30px;
        }
        
        #btn5{
            width: 150px;
            height: 50px;
            margin-top: 15px
        }

    </style>
        
    <main id ='myMain'>
        <input id="phone_value2"  type="text" placeholder="Вхідний виклик..." value="">
    
        <div>  
          <button type="submit" id="btn5">Прийняти виклик</button>
        </div>
    </main>   
`,

    init: function() {
       this.load();
    },
    
    load: function(data) {
    },
    
    afterViewInit: function () {
        
        let myBtn5 = document.getElementById('btn5');
        
        let number = () => {
            let r = [{ code: "phone_number", value: document.getElementById('phone_value2').value}];
                let r1 = JSON.stringify(r);
                let r2 = encodeURI(r1);
            window.open(location.origin + localStorage.getItem('VirtualPath') + "/sections/Appeals_2/add?DefaultValues="+r2, "_self");
        };
        myBtn5.addEventListener( "click", number )
    }

};
}());
