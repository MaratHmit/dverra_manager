warehouse-edit
    loader(if='{ loader }')
    div
        .btn-group
            a.btn.btn-default(href='#warehouse/warehouses') #[i.fa.fa-chevron-left]
            button.btn.btn-default(onclick='{ submit }', type='button')
                i.fa.fa-floppy-o
                |  Сохранить
            button.btn.btn-default(onclick='{ reload }', title='Обновить', type='button')
                i.fa.fa-refresh
        .h4 { isNew ? item.name || 'Новый склад' : item.name || 'Редактирование склада' }
        form(if='{ !loader }', onchange='{ change }', onkeyup='{ change }')
            .form-group(class='{ has-error: error.name }')
                .row
                    .col-md-4
                        .form-group
                            label.control-label Наименование
                            input.form-control(name='name', type='text', value='{ item.name }')
                            .help-block { error.name }
                    .col-md-4
                        .form-group
                            label.control-label Адрес
                            input.form-control(name='address', type='text', value='{ item.address }')
                    .col-md-4
                        .form-group
                            label.control-label Телефон
                            input.form-control(name='phone', type='text', value='{ item.phone }')
                .row
                    .col-md-12
                        .form-group
                            label.control-label Примечание
                            input.form-control(name='note', type='text', value='{ item.note }')

    script(type='text/babel').
        var self = this

        self.mixin('validation')
        self.mixin('permissions')
        self.mixin('change')
        self.item = {}

        self.rules = {
            name: 'empty',
        }

        self.afterChange = e => {
            let name = e.target.name
            delete self.error[name]
            self.error = {...self.error, ...self.validation.validate(self.item, self.rules, name)}
        }

        self.submit = () => {
            self.error = self.validation.validate(self.item, self.rules)

            if (!self.error) {
                API.request({
                    object: 'Warehouse',
                    method: 'Save',
                    data: self.item,
                    success(response) {
                        self.item = response
                        popups.create({title: 'Успех!', text: 'Информация о складе сохранена!', style: 'popup-success'})
                        if (self.isNew)
                            riot.route(`warehouse/warehouses/${self.item.id}`)
                        observable.trigger('warehouses-reload')
                        self.update()
                    }
                })
            }
        }

        self.reload = () => observable.trigger('warehouse-edit', self.item.id)

        observable.on('warehouse-new', () => {
            self.error = false
            self.item = {}
            self.isNew = true
            self.update()
        })

        observable.on('warehouses-edit', id => {
            self.error = false
            self.loader = true
            self.item = {}
            self.isNew = false
            self.update()

            API.request({
                object: 'Warehouse',
                method: 'Info',
                data: {id},
                success(response) {
                    self.item = response
                },
                complete() {
                    self.loader = false
                    self.update()
                }
            })
        })

