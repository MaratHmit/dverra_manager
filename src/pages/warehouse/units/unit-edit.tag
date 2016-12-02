| import '../groups/groups-units-list-modal.tag'

unit-edit
    loader(if='{ loader }')
    virtual(hide='{ loader }')
        .btn-group
            a.btn.btn-default(href='#warehouse') #[i.fa.fa-chevron-left]
            button.btn.btn-default(onclick='{ submit }', type='button')
                i.fa.fa-floppy-o
                |  Сохранить
            button.btn.btn-default(if='{ !isNew }', onclick='{ reload }', title='Обновить', type='button')
                i.fa.fa-refresh
        .h4  { isNew ? item.name || 'Добавление товара' : item.name || 'Редактирование товара' }

        form(action='', onchange='{ change }', onkeyup='{ change }', method='POST')
            .row
                .col-md-2
                    .form-group
                        label.control-label Код товара
                        input.form-control(name='code', type='text', value='{ item.code }')
                .col-md-4
                    .form-group(class='{ has-error: error.name }')
                        label.control-label Наименование
                        input.form-control(name='name', type='text', value='{ item.name }')
                        .help-block { error.name }
                .col-md-6
                    .form-group
                        label.control-label Группа
                        .input-group
                            input.form-control(name='nameGroup', value='{ item.nameGroup }', readonly)
                            span.input-group-addon(onclick='{ changeGroup }')
                                i.fa.fa-list
            .row
                .col-md-2
                    .form-group
                        label.control-label Цена закуп.
                        input.form-control(name='pricePurchase', type='number', min='0', step='1', value='{ parseFloat(item.pricePurchase) }')
                .col-md-2
                    .form-group
                        label.control-label Цена реализ.
                        input.form-control(name='price', type='number', min='0', step='1', value='{ parseFloat(item.price) }')
                .col-md-2
                    .form-group
                        label.control-label Кол-во
                        input.form-control(name='count', type='number', min='0', step='1', value='{ parseFloat(item.count) }')

    script(type='text/babel').
        var self = this

        self.isNew = false

        self.item = {}
        self.orders = []

        self.mixin('validation')
        self.mixin('permissions')
        self.mixin('change')

        self.rules = {
            name: 'empty'
        }

        self.afterChange = e => {
            let name = e.target.name
            delete self.error[name]
            self.error = {...self.error, ...self.validation.validate(self.item, self.rules, name)}
        }

        self.submit = e => {
            var params = self.item

            self.error = self.validation.validate(self.item, self.rules)

            if (!self.error) {
                API.request({
                    object: 'Unit',
                    method: 'Save',
                    data: params,
                    success(response) {
                        popups.create({title: 'Успех!', text: 'Изменения сохранены!', style: 'popup-success'})
                        self.item = response
                        self.update()
                        if (self.isNew)
                            riot.route(`/warehouse/${self.item.id}`)
                        observable.trigger('units-reload')
                    }
                })
            }
        }

        self.changeGroup = () => {
            modals.create('groups-units-list-modal', {
                type: 'modal-primary',
                submit() {
                    self.value = self.value || []
                    let items = this.tags['catalog-tree'].tags.treeview.getSelectedNodes()
                    if (items.length) {
                        self.item.idGroup = items[0].id
                        self.item.nameGroup = items[0].name
                    }
                    self.update()
                    this.modalHide()
                }
            })
        }

        observable.on('unit-new', () => {
            self.error = false
            self.isNew = true
            self.item = {}
            self.update()
        })

        observable.on('unit-edit', id => {
            var params = {id: id}
            self.error = false
            self.isNew = false
            self.loader = true
            self.item = {}

            API.request({
                object: 'Unit',
                method: 'Info',
                data: params,
                success: (response) => {
                    self.item = response
                    self.loader = false
                    self.update()
                },
                error() {
                    self.item = {}
                    self.loader = false
                    self.update()
                }
            })
        })

        self.reload = () => {
            self.item.id ? observable.trigger('unit-edit', self.item.id) : observable.trigger('unit-new')
        }

        self.on('mount', () => {
            riot.route.exec()
        })