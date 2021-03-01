(function() {
    return {
        
        recalc_content: function () {
            this.form.setControlValue('content', document.getElementById('content').value);
        },
        insertText: function ( id, text ) {
            //ищем элемент по id
              var txtarea = document.getElementById(id);
              //ищем первое положение выделенного символа
              var start = txtarea.selectionStart;
              //ищем последнее положение выделенного символа
              var end = txtarea.selectionEnd;
              // текст до + вставка + текст после (если этот код не работает, значит у вас несколько id)
              var finText = txtarea.value.substring(0, start) + text + txtarea.value.substring(end);
              // подмена значения
              txtarea.value = finText;
              // возвращаем фокус на элемент
              txtarea.focus();
              // возвращаем курсор на место - учитываем выделили ли текст или просто курсор поставили
              txtarea.selectionEnd = ( start == end )? (end + text.length) : end ;
        },
        init: function() {
            // this.form.onControlValueChanged('organization_id', this.onStreetsChanged);

////////////////////////////

                var css = `.menu-item {
                    border: 2px solid #ff6e40;
                    background: #ff6e40;
                    color: white;
                    display: inline-block;
                    text-align: center;
                    position: relative;
                    cursor: pointer;
                    border-radius: 5px;
                }
                .submenu {
                    width: 210px;
                    background: #efefef;
                    right: -4px;
                    padding: 5px;
                    display: none;
                    position: absolute;
                    cursor: pointer;
                }
                .submenu-btn {
                    width: 100%;
                    margin-top: 5px;
                    border: 1px solid #ff6e40;
                    border-radius: 5px;
                    background: #ff6e40;
                    color: white;
                    cursor: pointer;
                    display: table;
                }`;

                var htmlDiv = document.createElement('div');
                htmlDiv.innerHTML = '<p></p><style>' + css + '</style>';
                document.getElementsByTagName('head')[0].appendChild(htmlDiv.childNodes[1]);


                
                // var node = document.createElement("button");
                
                // var textnode = document.createTextNode("Тег");
                // node.appendChild(textnode);
                


                var t  = document.getElementById('content');
                var menu = document.createElement("span");
                menu.style.float = 'right';
                menu.style.width = '60px';
                menu.className = 'menu-item material-icons';
                menu.id = 'menu_item';
                menu.innerText = 'code';
                // node.appendChild(menu);
                t.parentElement.insertBefore(menu, t); 




                var submenu = document.createElement("div");
                submenu.className = 'submenu';
                menu.appendChild(submenu);

                //ADD BUTTONS
                var btn1 = document.createElement("button");
                btn1.className = 'submenu-btn';
                btn1.innerText = 'ПІБ заявника';
                btn1.id = 'AddTag1';
                submenu.appendChild(btn1);
                document.getElementById('AddTag1').addEventListener('click', function() {
                    this.insertText('content', '<ПІБ заявника>');
                    this.recalc_content();
                }.bind(this));

                var btn2 = document.createElement("button");
                btn2.className = 'submenu-btn';
                btn2.innerText = 'Адреса заявника';
                btn2.id = 'AddTag2';
                submenu.appendChild(btn2);
                document.getElementById('AddTag2').addEventListener('click', function() {
                    this.insertText('content', '<Адреса заявника>');
                    this.recalc_content();
                }.bind(this));

                var btn3 = document.createElement("button");
                btn3.className = 'submenu-btn';
                btn3.innerText = 'Директор КБУ';
                btn3.id = 'AddTag3';
                submenu.appendChild(btn3);
                document.getElementById('AddTag3').addEventListener('click', function() {
                    this.insertText('content', '<Директор КБУ>');
                    this.recalc_content();
                }.bind(this));

                var btn4 = document.createElement("button");
                btn4.className = 'submenu-btn';
                btn4.innerText = 'Номер питання';
                btn4.id = 'AddTag4';
                submenu.appendChild(btn4);
                document.getElementById('AddTag4').addEventListener('click', function() {
                    this.insertText('content', '<Номер питання>');
                    this.recalc_content();
                }.bind(this));

                var btn5 = document.createElement("button");
                btn5.className = 'submenu-btn';
                btn5.innerText = 'Дата реєстрації';
                btn5.id = 'AddTag5';
                submenu.appendChild(btn5);
                document.getElementById('AddTag5').addEventListener('click', function() {
                    this.insertText('content', '<Дата реєстрації>');
                    this.recalc_content();
                }.bind(this));

                var btn6 = document.createElement("button");
                btn6.className = 'submenu-btn';
                btn6.innerText = 'Тип питання';
                btn6.id = 'AddTag6';
                submenu.appendChild(btn6);
                document.getElementById('AddTag6').addEventListener('click', function() {
                    this.insertText('content', '<Тип питання>');
                    this.recalc_content();
                }.bind(this));

                var btn7 = document.createElement("button");
                btn7.className = 'submenu-btn';
                btn7.innerText = 'Місце проблема';
                btn7.id = 'AddTag7';
                submenu.appendChild(btn7);
                document.getElementById('AddTag7').addEventListener('click', function() {
                    this.insertText('content', '<Місце проблема>');
                    this.recalc_content();
                }.bind(this));

                var btn8 = document.createElement("button");
                btn8.className = 'submenu-btn';
                btn8.innerText = 'Організація-виконавець';
                btn8.id = 'AddTag8';
                submenu.appendChild(btn8);
                document.getElementById('AddTag8').addEventListener('click', function() {
                    this.insertText('content', '<Організація-виконавець>');
                    this.recalc_content();
                }.bind(this));

                var btn9 = document.createElement("button");
                btn9.className = 'submenu-btn';
                btn9.innerText = 'Директор організації';
                btn9.id = 'AddTag9';
                submenu.appendChild(btn9);
                document.getElementById('AddTag9').addEventListener('click', function() {
                    this.insertText('content', '<Директор організації>');
                    this.recalc_content();
                }.bind(this));

                var btn10 = document.createElement("button");
                btn10.className = 'submenu-btn';
                btn10.innerText = 'Номер Заходу';
                btn10.id = 'AddTag10';
                submenu.appendChild(btn10);
                document.getElementById('AddTag10').addEventListener('click', function() {
                    this.insertText('content', '<Номер Заходу>');
                    this.recalc_content();
                }.bind(this));

                var btn11 = document.createElement("button");
                btn11.className = 'submenu-btn';
                btn11.innerText = 'Клас Заходу';
                btn11.id = 'AddTag11';
                submenu.appendChild(btn11);
                document.getElementById('AddTag11').addEventListener('click', function() {
                    this.insertText('content', '<Клас Заходу>');
                    this.recalc_content();
                }.bind(this));

                var btn12 = document.createElement("button");
                btn12.className = 'submenu-btn';
                btn12.innerText = 'Відповідальний за Захід';
                btn12.id = 'AddTag12';
                submenu.appendChild(btn12);
                document.getElementById('AddTag12').addEventListener('click', function() {
                    this.insertText('content', '<Відповідальний за Захід>');
                    this.recalc_content();
                }.bind(this));

                var btn13 = document.createElement("button");
                btn13.className = 'submenu-btn';
                btn13.innerText = 'Дата початку Заходу';
                btn13.id = 'AddTag13';
                submenu.appendChild(btn13);
                document.getElementById('AddTag13').addEventListener('click', function() {
                    this.insertText('content', '<Дата початку Заходу>');
                    this.recalc_content();
                }.bind(this));

                var btn14 = document.createElement("button");
                btn14.className = 'submenu-btn';
                btn14.innerText = 'Планова дата завершення';
                btn14.id = 'AddTag14';
                submenu.appendChild(btn14);
                document.getElementById('AddTag14').addEventListener('click', function() {
                    this.insertText('content', '<Планова дата завершення>');
                    this.recalc_content();
                }.bind(this));

                ///////////////////

        document.getElementById('menu_item').onmouseover= function(event) {
            var target = event.target; // где был клик?
            if (target.className == 'menu-item material-icons') {
                var s=target.getElementsByClassName('submenu');
                closeMenu();
                s[0].style.display='block';
            }
        };
        
        document.onmousemove=function(event) {
            var target = event.target; // где был клик?
            // console.log(event.target);
            if (target.className!='menu-item material-icons' && target.className!='submenu' && target.className!='submenu-btn') {
                closeMenu();
            }
        }
        function closeMenu(){
            var menu=document.getElementById('menu_item');
            var subm=document.getElementsByClassName('submenu');
            for (var i=0; i<subm.length; i++) {
                subm[i].style.display="none";
            }
        }





        },
        onStreetsChanged: function(dis_id) {
            if (typeof dis_id === 'string') {
                return
            } else if (dis_id == null) {
                this.form.setControlValue('position_id', null);
                let dependParams = [{ parameterCode: '@organization_id', parameterValue: dis_id }];
                this.form.setControlParameterValues('position_id', dependParams);
                this.form.disableControl('position_id');
            } else {
                let dependParams = [{ parameterCode: '@organization_id', parameterValue: dis_id }];
                this.form.setControlParameterValues('position_id', dependParams);
                this.form.enableControl('position_id');
            }
        }
    };
}());