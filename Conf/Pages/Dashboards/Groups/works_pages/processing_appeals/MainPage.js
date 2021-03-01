(function() {
    return {
        init: function() {
            let select2LibraryJS = 'select2LibraryJS';
            if (!document.getElementById(select2LibraryJS)) {
                let head = document.getElementsByTagName('head')[0];
                let script = document.createElement('script');
                script.id = 'jQueryLibraryJS';
                script.type = 'text/javascript';
                script.src = 'https://cdnjs.cloudflare.com/ajax/libs/jquery/3.4.1/jquery.min.js';
                head.appendChild(script);
                script.onload = function() {
                    let script2 = document.createElement('script');
                    script2.id = 'select2LibraryJS';
                    script2.type = 'text/javascript';
                    script2.src = 'https://cdnjs.cloudflare.com/ajax/libs/select2/4.0.9/js/select2.min.js';
                    head.appendChild(script2);
                    script2.onload = function() {
                        let style = document.createElement('style');
                        let styleSelect = document.createElement('link');
                        styleSelect.rel = 'stylesheet';
                        styleSelect.href =
                            'https://cdnjs.cloudflare.com/ajax/libs/select2/4.0.6-rc.0/css/select2.min.css';
                        styleSelect.type = 'text/css';
                        let tag_head = document.getElementsByTagName('head');
                        tag_head[0].appendChild(styleSelect);
                        style.onload = function() {
                            let messageSelect = {
                                name: 'LoadLib',
                                package: {
                                    value: 1
                                }
                            }
                            self.messageService.publish(messageSelect);
                        }.bind(self);
                    }.bind(self);
                }.bind(self);
            }
            this.showPreloader = false;
            this.sub = this.messageService.subscribe('showPagePreloader', this.showMyPreloader, this);
            this.sub1 = this.messageService.subscribe('hidePagePreloader', this.hideMyPreloader, this);
            this.sub2 = this.messageService.subscribe('afterRenderTable', this.createCustomStyle, this);
            this.sub3 = this.messageService.subscribe('createMasterDetail', this.createMasterDetail, this);
            this.sub4 = this.messageService.subscribe('exportExcel', this.createExcelWorkbook, this);
        },
        createExcelWorkbook: function(message) {
            const data = message.data;
            const self = message.context;
            const columns = message.columns;
            const workbook = self.createExcel();
            const worksheet = workbook.addWorksheet('Заявки', {
                pageSetup:{
                    orientation: 'landscape',
                    fitToPage: false,
                    margins: {
                        left: 0.4, right: 0.3,
                        top: 0.4, bottom: 0.4,
                        header: 0.0, footer: 0.0
                    }
                }
            });
            this.excelHeadRowStart = 4;
            this.excelHeadRowEnd = 4;
            const columnsProperties = [];
            const rows = [];
            this.setColumnsProperties(columns, columnsProperties, worksheet);
            this.setTableHeader(columns, worksheet);
            this.setWorksheetTitle(worksheet, columns.length);
            this.setTableValues(data, worksheet, rows);
            this.setTableRowsStyles(worksheet, rows);
            self.helperFunctions.excel.save(workbook, 'Заявки', this.hidePagePreloader);
        },
        setColumnsProperties: function(columns, columnsProperties, worksheet) {
            for (let i = 0; i < columns.length; i++) {
                const column = columns[i];
                let header;
                let index = 0;
                let width = 19;
                let columnProp = { header, width, index };
                if(column.columns) {
                    for (let j = 0; j < column.columns.length; j++) {
                        const subColumn = column.columns[j];
                        columnProp.index += 1;
                        columnProp.header = subColumn.caption;
                        columnsProperties.push(columnProp);
                    }
                } else {
                    columnProp.header = column.caption;
                    columnProp.index += 1;
                    columnsProperties.push(columnProp);
                }
            }
            worksheet.columns = columnsProperties;
        },
        setTableHeader: function(columns, worksheet) {
            let position = 0;
            for (let i = 0; i < columns.length; i++) {
                const column = columns[i];
                position += 1;
                worksheet.mergeCells(this.excelHeadRowStart, position, this.excelHeadRowEnd, position);
                const cell = worksheet.getCell(this.excelHeadRowEnd, position);
                cell.value = column.caption;
                this.setCellStyle(cell);
            }
            this.lastPosition = position;
        },
        setWorksheetTitle: function(worksheet, length) {
            worksheet.mergeCells(1, 1, 1, length);
            const title = worksheet.getCell(1, 1);
            title.value = 'Інформація';
            worksheet.mergeCells(2, 1, 2, length);
            const description = worksheet.getCell(2, 1);
            description.value = 'про звернення громадян, що надійшли до Служби мера'
        },
        setTableValues: function(data, worksheet, rowNumbers) {
            for (let i = 0; i < data.rows.length; i++) {
                const rowData = data.rows[i];
                const rowStart = this.excelHeadRowStart + 1 + i;
                rowNumbers.push(rowStart);
                for (let j = 1; j < rowData.values.length - 3; j++) {
                    if(j !== 8 && j !== 9) {
                        const value = rowData.values[j];
                        const cell = worksheet.getCell(rowStart, j);
                        if (j === 2 || j === 5) {
                            cell.value = this.changeDateTimeValues(value);
                        } else {
                            cell.value = value;
                        }
                        this.setCellStyle(cell);
                    }
                }
            }
        },
        setTableRowsStyles: function(worksheet, rowNumbers) {
            worksheet.getRow(1).font = {
                name: 'Times New Roman',
                family: 4,
                size: 14,
                underline: false,
                bold: true,
                italic: false
            };
            worksheet.getRow(1).alignment = { vertical: 'middle', horizontal: 'center', wrapText: true };
            worksheet.getRow(2).font = {
                name: 'Times New Roman',
                family: 4,
                size: 14,
                underline: false,
                bold: true,
                italic: false
            };
            worksheet.getRow(2).alignment = { vertical: 'middle', horizontal: 'center', wrapText: true };
            worksheet.getRow(3).font = {
                name: 'Times New Roman',
                family: 4,
                size: 10,
                underline: false,
                bold: true,
                italic: false
            };
            worksheet.getRow(3).alignment = { vertical: 'middle', horizontal: 'center', wrapText: true };
            worksheet.getRow(4).font = {
                name: 'Times New Roman',
                family: 4,
                size: 10,
                underline: false,
                bold: true,
                italic: false
            };
            worksheet.getRow(4).alignment = { vertical: 'middle', horizontal: 'center', wrapText: true };
            worksheet.getRow(1).height = 30;
            worksheet.getRow(2).height = 30;
            worksheet.getRow(3).height = 40;
            worksheet.getRow(4).height = 40;
            rowNumbers.forEach(number => {
                worksheet.getRow(number).height = 90;
                worksheet.getRow(number).font = {
                    name: 'Times New Roman',
                    family: 4,
                    size: 10,
                    underline: false,
                    italic: false
                };
                worksheet.getRow(number).alignment = { vertical: 'middle', horizontal: 'center', wrapText: true };
                worksheet.getCell('A' + number).alignment = { vertical: 'middle', horizontal: 'left', wrapText: true };
            });
        },
        setCellStyle: function(cell) {
            cell.border = { top: {style:'thin'}, left: {style:'thin'}, bottom: {style:'thin'}, right: {style:'thin'} };
            cell.alignment = { vertical: 'middle', horizontal: 'center', wrapText: true };
            cell.font = { name: 'Times New Roman', family: 4, size: 10, underline: false, bold: false , italic: false };
        },
        changeDateTimeValues: function(value) {
            let date = new Date(value);
            let dd = date.getDate().toString();
            let mm = (date.getMonth() + 1).toString();
            let yyyy = date.getFullYear().toString();
            dd = dd.length === 1 ? '0' + dd : dd;
            mm = mm.length === 1 ? '0' + mm : mm;
            return `${dd}.${mm}.${yyyy}`;
        },
        createMasterDetail: function(message) {
            const fields = message.fields;
            const data = message.currentEmployeeData;
            const container = message.container;
            const elementsWrapper = this.createElement('div', {className: 'elementsWrapper'});
            container.appendChild(elementsWrapper);
            for (const field in fields) {
                for (const property in data) {
                    if(property === field) {
                        if(data[property] === null || data[property] === undefined) {
                            data[property] = '';
                        }
                        const content = this.createElement('div',
                            {
                                className: 'content',innerText: data[property]
                            }
                        );
                        const caption = this.createElement('div',
                            {
                                className: 'caption',innerText: fields[field], style: 'min-width: 200px'
                            }
                        );
                        const masterDetailItem = this.createElement('div',
                            {
                                className: 'element', style: 'display: flex; margin: 15px 10px'
                            },
                            caption, content
                        );
                        elementsWrapper.appendChild(masterDetailItem);
                    }
                }
            }
        },
        showMyPreloader: function() {
            this.showPagePreloader('Зачекайте, данні завантажуються');
        },
        hideMyPreloader: function() {
            this.hidePagePreloader();
        },
        createCustomStyle: function() {
            const elements = Array.from(document.querySelectorAll('.dx-datagrid-export-button'));
            elements.forEach(element => {
                const spanElement = this.createElement('span', { className: 'dx-button-text', innerText: 'Excel'});
                if(element.firstElementChild.childElementCount === 1) {
                    element.firstElementChild.appendChild(spanElement);
                }
            });
        },
        createElement: function(tag, props, ...children) {
            const element = document.createElement(tag);
            Object.keys(props).forEach(key => element[key] = props[key]);
            if(children.length > 0) {
                children.forEach(child =>{
                    element.appendChild(child);
                });
            } return element;
        },
        destroy: function() {
            this.sub.unsubscribe;
            this.sub1.unsubscribe;
            this.sub2.unsubscribe;
            this.sub3.unsubscribe;
        }
    };
}());
