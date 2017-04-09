| import 'pages/warehouse/units/units-list-select-modal.tag'

product-edit-modifications
    .row
        .col-md-12
            catalog-static(name='{ opts.name }', cols='{ cols }', rows='{ value }', handlers='{ handlers }',
            add='{ opts.add }', dblclick='{ opts.dblclick }')
                #{'yield'}(to='toolbar')
                    button.btn.btn-primary(if='{ selectedCount }',
                    type='button', onclick='{ parent.opts.edit }', title='Редактировать')
                        i.fa.fa-fw.fa-pencil
                    button.btn.btn-primary(if='{ selectedCount }',
                    type='button', onclick='{ parent.opts.clone }', title='Клонировать')
                        i.fa.fa-fw.fa-clone
                #{'yield'}(to='body')
                    datatable-cell(name='composition')
                        ul.list-unstyled
                            li(each='{ row.units }') { name }
                    datatable-cell(name='price')
                        input(name='price', value='{ row.price }', readonly='true')
                    datatable-cell(name='count')
                        input(name='count', value='{ row.count }', readonly='true')
                    datatable-cell(each='{ item, i in parent.parent.parent.newCols }', name='{ item.name }') { row.params[i].value }


    script(type='text/babel').
        let self = this

        self.value = opts.value || []
        self.cols = []
        self.newCols = []

        self.handlers = {
            change(e) {
                if (!e.target.name) return

                var bannedTypes = ['checkbox', 'file', 'color', 'range', 'number']

                if (e.target && bannedTypes.indexOf(e.target.type) === -1) {
                    var selectionStart = e.target.selectionStart
                    var selectionEnd = e.target.selectionEnd
                }

                if (e.target && e.target.type === 'checkbox' && e.target.name)
                    e.item.row[e.target.name] = e.target.checked
                if (e.target && e.target.type !== 'checkbox' && e.target.name)
                    e.item.row[e.target.name] = e.target.value
                if (e.currentTarget.tagName !== 'FORM' && e.currentTarget.name !== '')
                    e.item.row[e.currentTarget.name] = e.currentTarget.value

                if (e.target && bannedTypes.indexOf(e.target.type) === -1) {
                    this.update()
                    e.target.selectionStart = selectionStart
                    e.target.selectionEnd = selectionEnd
                }
            }
        }

        self.on('update', () => {
            self.value = opts.value || []

            self.initCols = [
                {name: 'composition', value: 'Состав'},
                {name: 'price', value: 'Цена'},
                {name: 'count', value: 'Кол-во'},
            ]

            self.root.name = opts.name || ''
            self.newCols = []

            if (self.value.length &&
                self.value[0].params &&
                self.value[0].params instanceof Array) {
                self.newCols = self.value[0].params.map((item, i) => {
                    return { name: i, value: item.name }
                })
            }

            self.cols = [...self.initCols, ...self.newCols]
        })

product-edit-modifications-add-modal
    bs-modal
        #{'yield'}(to="title")
            .h4.modal-title Торговое предложение
        #{'yield'}(to="body")
            form(onchange='{ change }')
                .form-group(each='{ param, i in features }', class='{ has-error: parent.error[item.id] }')
                    label.control-label { param.name }
                    select.form-control(name='{ param.idFeature }', value='{ param.value }', onchange='{ changeFeature }')
                        option(each='{ values, i in param.values }', value='{ values.id }',
                            selected='{ handlers.isSelected(param.idFeature, values.id) }') { values.value }
                    .help-block { parent.error[param.id] }
                label Состав торгового предложения
                catalog-static(name='units', add='{ addUnit }',
                    cols='{ unitsCols }', rows='{ item.units }')
                    #{'yield'}(to='body')
                        datatable-cell(name='id') { row.id }
                        datatable-cell(name='name') { row.name }
                        datatable-cell(name='price') { row.price }
        #{'yield'}(to='footer')
            button(onclick='{ modalHide }', type='button', class='btn btn-default btn-embossed') Закрыть
            button(onclick='{ submit }', type='button', class='btn btn-primary btn-embossed') Выбрать

    script(type='text/babel').
        var self = this

        self.on('mount', () => {
            let modal = self.tags['bs-modal']
            modal.item = opts.item
            modal.mixin('validation')
            modal.mixin('change')
            modal.error = {}
            modal.item.params = modal.item.params || []

            modal.unitsCols = [
                {name: 'id', value: '#'},
                {name: 'name', value: 'Наименование'},
                {name: 'price', value: 'Цена'},
            ]

            modal.changeFeature = e => {

                let id = e.target.name
                let items = modal.item.params.filter(i => i.idFeature == id)
                if (!items.length)
                    modal.item.params.push({ idFeature: id })

                let originalItems = modal.features.filter(i => i.idFeature == id)
                if (originalItems[0].values.filter(i => i.id == e.target.value).length) {
                    modal.item.params.forEach(param => {
                        if (param.idFeature == originalItems[0].idFeature) {
                            param.idValue = e.target.value
                            param.value = originalItems[0].values.filter(i => i.id == e.target.value)[0].value
                            param.name = originalItems[0].name
                        }
                    })
                }
                let name = e.target.name
                delete modal.error[name]
            }

            API.request({
                object: 'ProductType',
                method: 'Info',
                data: {id: opts.idType},
                success(response) {
                    modal.features = response.features

                    if (!modal.item.params.length) {
                        modal.features.forEach(feature => {
                            if (feature.values.length) {
                                modal.item.params.push({
                                    idFeature: feature.id,
                                    name: feature.name,
                                    idValue: feature.values[0].id,
                                    value: feature.values[0].value,
                                })
                            }
                        })
                    }

                    modal.features = modal.features.map(item => {
                        let newItem = {
                            idFeature: item.id,
                            name: item.name,
                            idValue: null,
                            value: null,
                            values: item.values
                        }
                        return {...newItem}
                    })
                },
                complete() {
                    self.update()
                }
            })

            modal.submit = () => {
                let count = 0, price = 0
                modal.item.units.forEach(unit => {
                    count = Math.min(count, unit.count * 1)
                    price += unit.price * 1
                })
                modal.item.count = count
                modal.item.price = price
                if (typeof opts.submit === 'function')
                    opts.submit.apply(modal)
            }

            modal.addUnit = () => {
                let item = modal.item
                modals.create('units-list-select-modal', {
                    type: 'modal-primary',
                    size: 'modal-lg',
                    submit() {
                        item.units = item.units || []

                        let items = this.tags.catalog.tags.datatable.getSelectedRows()

                        let ids = item.units.map(item => {
                            return item.id
                        })

                        items.forEach(function (unit) {
                            if (ids.indexOf(unit.id) === -1) {
                                item.units.push(unit)
                            }
                        })

                        self.update()
                        this.modalHide()
                    }
                })
            }

            var isSelected = (idFeature, idValue) => {
                let param = modal.item.params.filter(i => (i.idFeature == idFeature && i.idValue == idValue))
                return param.length ? true : false
            }

            modal.handlers = { isSelected: isSelected }

        })