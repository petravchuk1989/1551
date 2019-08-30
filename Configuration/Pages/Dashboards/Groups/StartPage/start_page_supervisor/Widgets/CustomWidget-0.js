(function () {
  return {
    // title: '',
    // hint: '',
    // formatTitle: function() {},
    customConfig:
                `
                    <style>
                    .modal1 {
                            display: none;
                            position: fixed;
                            z-index: 1; 
                            left: 0;
                            bottom:-40px;
                            width: 100%;
                            height: 100%; 
                            overflow: auto; 
                            background-color: rgb(0,0,0); 
                            background-color: rgba(0,0,0,0.4);
                        }
                        
                        .modal1-content {
                            background-color: #fefefe;
                            border-radius:5px;
                            margin: 15% auto; 
                            padding: 20px;
                            border: 1px solid #888;
                            width: 40%; 
                            box-shadow: rgb(178, 178, 178) 1px 1px 2px;
                        }
                        
                        .close1 {
                            position: relative;
                            top: -25px;
                            right: -10px;
                            color: #aaa;
                            float: right;
                            font-size: 28px;
                            font-weight: bold;
                        }
                        
                        .close1:hover,
                        .close1:focus {
                            color: black;
                            text-decoration: none;
                            cursor: pointer;
                        }
                        
                        .header-label {
                            text-align: center;
                            color: #131313;
                            margin: 32.5px;
                            font-size: 30px;
                            line-height: 18px;
                        }
                        .group-btns {
                            margin-top: 3em;
                            display: -webkit-box;
                            display: -ms-flexbox;
                            display: flex;
                            justify-content: space-around; /* просто не хватило этого */
                            -ms-flex-wrap: wrap;
                            flex-wrap: wrap;
                        }
                        
                        .group-btns .group {
                            width: 15.00%;
                            height: 200px;
                            cursor: pointer;
                            position: relative;
                            background-color: #F8F8F8;
                            border-radius: 15px;
                            display: flex;
                            flex-direction: column;
                            justify-content: space-around;
                            margin: 2% 5%;
                        }
                        .group-btns .group .icon {
                            text-align: center;
                        }
                        .group-btns .group .icon i {
                            font-size: 70px;
                        }
                        .group-btns .group .description {
                            text-align: center;
                            color: #131313;
                            font-size: 20px;
                            line-height: 18px;
                        }
                        .group-btns .group .border-bottom {
                            position: absolute;
                            width: calc(100% - 40px);
                            bottom: 0;
                            left: 20px;
                            box-shadow: 0 0 1px 1px rgba(0,0,0,.1);
                        }
                        .group-btns .group .border-right {
                            position: absolute;
                            height: calc(100% - 40px);
                            top: 20px;
                            right: 0;
                            box-shadow: 0 0 1px 1px rgba(0,0,0,.1);
                        }
                        .elementIcon{
                            padding-top: 25px;
                        }
                    
                    .fc-event{
                        font-size: 1.6em;
                        border-top: 1px solid #9e9e9e2e;
                       /* margin-top: 0.5em;*/
                            cursor: pointer;
                    }
                    .fc-event:hover{
                            background-color: #69a5d636;
                    }
                    </style>
                
                
                        <div ="" class="header-label"> КБУ "Контактний центр міста Києва 1551"</div>
                    <section ="" class="group-btns">
                    
                      <!--
                        <input id="phone_value2"  type="text" placeholder="Вхідний виклик..." value="">
                      -->
                      
                      <div ="" class="group" tabindex="0" id = "btn1">
                        <div ="" class="icon">
                          <i ="" class="material-icons elementIcon" style="color:#f44336;"> contact_phone </i>
                        </div>
                        <div ="" class="description"> Реєстрація Звернення за дзвінком </div>
                        <div ="" class="border-bottom"></div>
                        <div ="" class="border-right"></div>
                      </div>
                      
                      <div ="" class="group" tabindex="0" onclick="javascript:window.location='`+location.origin + localStorage.getItem('VirtualPath')+ `/sections/Appeals_from_Site'">
                        <div ="" class="icon">
                          <i ="" class="material-icons elementIcon" style="color:#ff7961;"> view_list </i>
                        </div>
                        <div ="" class="description"> Перегляд Звернень з сайту</div>
                        <div ="" class="border-bottom"></div>
                        <div ="" class="border-right"></div>
                      </div>

                      <div ="" class="group" tabindex="0" onclick="javascript:window.location='`+location.origin + localStorage.getItem('VirtualPath')+ `/sections/Appeals'">
                        <div ="" class="icon">
                          <i ="" class="material-icons elementIcon" style="color: #2196F3;"> pageview </i>
                        </div>
                        <div ="" class="description"> Пошук Звернень </div>
                        <div ="" class="border-bottom"></div>
                        <div ="" class="border-right"></div>
                      </div>

                      <div ="" class="group" tabindex="0" onclick="javascript:window.location='`+location.origin + localStorage.getItem('VirtualPath')+ `/dashboard/page/poshuk_table'">
                        <div ="" class="icon">
                          <i ="" class="material-icons elementIcon" style="color: #2196F3;"> find_in_page </i>
                        </div>
                        <div ="" class="description"> Розширений пошук </div>
                        <div ="" class="border-bottom"></div>
                        <div ="" class="border-right"></div>
                      </div>
                      
                      <div ="" class="group" tabindex="0" onclick="javascript:window.location='`+location.origin + localStorage.getItem('VirtualPath')+ `/dashboard/page/referrals_from_the_site'">
                        <div ="" class="icon">
                          <i ="" class="material-icons elementIcon" style="color: #2196F3;"> desktop_windows </i>
                        </div>
                        <div ="" class="description"> Реєстрація Звернень з сайту </div>
                        <div ="" class="border-bottom"></div>
                        <div ="" class="border-right"></div>
                      </div>
                      
                      <div ="" class="group" tabindex="0" onclick="javascript:window.location='`+location.origin + localStorage.getItem('VirtualPath')+ `/dashboard/page/prozvon'">
                        <div ="" class="icon">
                          <i ="" class="material-icons elementIcon" style="color: #2196F3;"> perm_phone_msg </i>
                        </div>
                        <div ="" class="description"> Прозвон </div>
                        <div ="" class="border-bottom"></div>
                        <div ="" class="border-right"></div>
                      </div>
                      
                      
                      <div ="" id="selected_group_id" class="group" tabindex="0"  >
                        <div ="" class="icon">
                          <i ="" class="material-icons elementIcon" style="color: #6ec6ff;"> mail </i>
                        </div>
                        <div ="" class="description"> Реєстрація Звернення згідно листа </div>
                        <div ="" class="border-bottom"></div>
                        <div ="" class="border-right"></div>
                      </div>
                      
                      
                      

                      
                   <!--     <div ="" class="group" tabindex="0"  onclick="javascript:window.location='`+location.origin + localStorage.getItem('VirtualPath')+ `/sections/Polls/add'">
                        <div ="" class="icon">
                          <i ="" class="material-icons elementIcon" style="color:#FBC02D;"> event_note </i>
                        </div>
                        <div ="" class="description"> Проведення опитування </div>
                        <div ="" class="border-bottom"></div>
                        <div ="" class="border-right"></div>
                      </div>
                      
                  <div ="" class="group" tabindex="0" onclick="javascript:window.location='`+location.origin + localStorage.getItem('VirtualPath')+ `/dashboard/home/CityPublicTransport'">
                        <div ="" class="icon">
                          <i ="" class="material-icons elementIcon" style="color: #FFB300;">directions_bus </i>
                        </div>
                        <div ="" class="description"> Київпастранс </div>
                        <div ="" class="border-bottom"></div>
                        <div ="" class="border-right"></div>
                      </div>-->
                    
                    </section>
                
                
                
                
                
                    <!-- The modal1 -->
                    <div id="myModal1" class="modal1">
                        <!-- modal1 content -->
                        <div class="modal1-content">
                            <span class="close1">&times;</span>
                            <p style="text-align:center;" id="title_text" > Виберіть тип звернення </span> </p>
                            <div style="text-align:left; padding-top: 40px;" id='external-events-list' class="new_list">
                                
                            </div>
                            
                        </div>
                        
                    </div>
                
                `
    ,
    // onclick="javascript:window.location='`+location.origin + localStorage.getItem('VirtualPath')+ `/sections/CreateAppeal/add'"
    init: function() {
                let executeQuery = {
                                    queryCode: 'GetReceiptSources',
                                    limit: -1,
                                    parameterValues: []
                                    };
                this.queryExecutor(executeQuery, this.load, this);
                                                
    },
    initValue: function(){
        
    },
    load: function(data) {
        
        var modal = document.getElementById('myModal1');
        var span = document.getElementsByClassName("close1")[0];
        
        span.onclick = function() {
            modal.style.display = "none";
        };
        
        window.onclick = function(event) {
            if (event.target == modal) {
                modal.style.display = "none";
            }
        };
                            
                            
                            
            if (document.getElementsByClassName('new_list')) {
                       var list = document.getElementById("external-events-list"); 
                       var list_count = list.childNodes.length;
                      for (var i=0;i<list_count;i++){
                          list.removeChild(list.childNodes[0]);
                      }
            }; 
                
            if (data) {
                if (data.rows.length > 0) {
                       for (var i=0;i<data.rows.length;i++){
                           let r = document.getElementById('phone_value2').value;
           
                                        var iDiv = document.getElementById('external-events-list');
                                        var iDiv2 = document.createElement('div');
                                        // iDiv2.style = "";
                                        iDiv2.innerHTML = ` `+data.rows[i].values[1]+`
                                                           <input type="hidden" name="elem_id" value="`+data.rows[i].values[0]+`">
                                                            `;
                                        iDiv2.id = 'row_table2_'+ (Number(i));
                                        // iDiv2.style = 'border-left: 10px solid '+data.rows[i].values[10]+';';
                                        iDiv2.className = 'fc-event';
                                        iDiv.appendChild(iDiv2);
                                      
                                    iDiv2.addEventListener('click', function(){
                                        
                                        let r = document.getElementById('phone_value2').value;
                                        
                                        if (r == "") {
                                            r = "0000000000";
                                        };
                                        
                                         window.open(location.origin + localStorage.getItem('VirtualPath') + "/sections/CreateAppeal/add?phone="+r+"&type="+event.target.children[0].value)
                                    }.bind(this)); 
                        };      
                     
                };  
            };     
           // <a id="title_url" href="`+location.origin + localStorage.getItem('VirtualPath')+ `/sections/CreateAppeal/add?phone=0000000000&type=`+data.rows[i].values[0]+`" target="_self">`+data.rows[i].values[1]+`</a>
                                                                                    
                            
        var btn_selected_group_id = document.getElementById('selected_group_id');
        btn_selected_group_id.onclick = function () {  
                var modal2 = document.getElementById('myModal1');
                modal2.style.display = "block";
        }.bind(this);
        
        
    },
    //  http://crm1551.callway.com.ua:8076/sections/CreateAppeal/add?phone=(044)2356767&type=1
    // window.open(location.origin + localStorage.getItem('VirtualPath') + "/sections/CreateAppeal/add?DefaultValues="+r2, "_self");, { code: "type", value: 1}
    afterViewInit:function(){
        let btn = document.getElementById('btn1');
        let number = () => {
            // let r = [{ code: "Phone", value: document.getElementById('phone_value2').value}];
            let r = document.getElementById('phone_value2').value;
                let r1 = JSON.stringify(r);
                let r2 = encodeURI(r1);
                // console.log(r);
                // console.log(r1);
                // console.log(r2);
            // window.open(location.origin + localStorage.getItem('VirtualPath') + "/sections/CreateAppeal/add?phone="+r"+"&type=1");
            window.open(location.origin + localStorage.getItem('VirtualPath') + "/sections/CreateAppeal/add?phone="+r+"&type=1")
        };
        btn.addEventListener( "click", number )
        
        
        
        
        
        // onclick="javascript:window.location='`+location.origin + localStorage.getItem('VirtualPath')+ `/sections/CreateAppeal/add?phone=0000000000&type=5'"
        
    }
}

;
}());
