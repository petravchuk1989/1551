(function() {
    return {
        title: '',
        hint: '',
        formatTitle: function() {},
        customConfig:
                    `
                    <div class='container'>
                        <div class='main' id='main'>

                        </div>
                    </div>
                    `
        ,
        afterViewInit: function() {
            let executeQuery = {
                queryCode: 'ReferenceAPI_Request_SelectRows',
                parameterValues: [],
                limit: -1
            };
            this.queryExecutor(executeQuery, this.openApi, this);
        },
        openApi({rows}) {
            const arr = rows.map(elem=>JSON.parse(elem.values[0]))
            this.load(arr)
        },
        load: function(data) {
            const title = document.getElementById('title');
            title.remove();
            const apiArr = data[0]
            const mainCon = document.getElementById('main');
            const unique = apiArr.map(elem=>elem.about.category);
            const uniqueArr = unique.filter((elem,index)=>unique.indexOf(elem) === index)
            const categories = uniqueArr.map(item=>{
                const index = uniqueArr.indexOf(item)
                return `<li class='category-item item${index}' data-name='${item}'><a href='#' class='category-link' >${item} 
               </a><div class='api-main-con'></div></li>`
            }).join('');
            mainCon.insertAdjacentHTML('beforeend',`<ul class='category-list'>${categories}</ul>`)
            const categoryNodes = Array.from(document.querySelectorAll('.category-item'))
            apiArr.map(elem=>{
                const responsesForInsert = elem.response.map(res=> {
                    return `<div class='response request-names'>
                    <h4 class='info-title request-names-val first'>${res.status}</h4>
                    <p class='headers request-names-val'><span class='info-text response-obj'>${res.value}</span></p>
                    </div>`
                })
                const int2 = `<div class='api-con' data-category='${elem.about.category}'>
                <div class='api ${(elem.request.method).toLowerCase()}'>
                    <span class='api-method ${(elem.request.method).toLowerCase()}'>${elem.request.method}</span>
                    <span class='api-description '>${elem.about.name}</span>
                </div>
                    <div class='api-info'>
                        <div class='request-con'>
                            <div class='request-con-title block-api-title'>
                                <h4 class='request-title block-title'>Parameters</h4>
                            </div>
                                <div class='request-con-info con-info'>
                                    <div class='request-auth'>
                                        <div class='request-names'>
                                            <h4 class='info-title request-names-val first'>Name</h4>
                                            <h4 class='info-title request-names-val'>Description</h4>
                                        </div>
                                        <div class='request-descriptions'>
                                            <div class='request-about-titles'>
                                                <h4 class='info-title'>body</h4>
                                            </div>
                                            <div class='request-about-descriptions info-title'>
                                                <h4 class='request-description'>${elem.about.description}</h4>
                                                <h4 class='info-title'>type: ${elem.request.body[0].type}</h4>
                                                <h4 class='info-title'>value:
                                                 <span class='info-text'>${elem.request.body[0].value}</span></h4>
                                                <h4 class='info-title'>url: <span class='info-text'>${elem.request.url}</span></h4>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            <div class='response-con-title block-api-title'>
                                <h4 class='response-title block-title'>Responses</h4>
                            </div>    
                            <div class='response-con-info con-info'>
                                <div class='request-names'>
                                    <h4 class='info-title request-names-val first'>Code</h4>
                                    <h4 class='info-title request-names-val'>Description</h4>
                                </div>
                                <div class='responses'> 
                                    ${responsesForInsert}
                                </div>
                            </div>
                        </div>

                    </div>
                </div>`
                categoryNodes.forEach(item=>{
                    if(item.dataset.name === elem.about.category) {
                        const apiCon = item.querySelector('.api-main-con')
                        apiCon.insertAdjacentHTML('beforeend',`${int2}`)
                    }
                })
                this.toggleListener()
                return int2
            })
        },
        toggleListener() {
            const categoryNodes = Array.from(document.querySelectorAll('.category-link'))
            const api = Array.from(document.querySelectorAll('.api'))
            categoryNodes.forEach(elem=>elem.addEventListener('click',this.toggleInfo))
            api.forEach(elem=>elem.addEventListener('click',this.toggleMethod))

        },
        toggleInfo(e) {
            e.preventDefault()
            const con = e.target.closest('.category-item')
            const int = con.querySelector('.api-main-con')
            if(int.classList.contains('active')) {
                $(int).fadeOut()
                int.classList.remove('active')
            } else {
                $(int).fadeIn()
                int.classList.add('active')
            }
        },
        toggleMethod(e) {
            const con = e.target.closest('.api-con')
            const int = con.querySelector('.api-info')
            if(int.classList.contains('active')) {
                $(int).fadeOut()
                int.classList.remove('active')
            } else {
                $(int).fadeIn()
                int.classList.add('active')
            }
        }
    };
}());
