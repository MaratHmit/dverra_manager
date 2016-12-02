| import parallel from 'async/parallel'

service-edit
    loader(if='{ loader }')
    virtual(hide='{ loader }')
        .btn-group
            a.btn.btn-default(href='#settings/services') #[i.fa.fa-chevron-left]
            button.btn.btn-default(onclick='{ submit }', type='button')
                i.fa.fa-floppy-o
                |  Сохранить
            button.btn.btn-default(if='{ !isNew }', onclick='{ reload }', title='Обновить', type='button')
                i.fa.fa-refresh
        .h4 Параметры сервиса:
            nbsp
            a(href='{ item.url }') { item.name }

        form(action='', onchange='{ change }', onkeyup='{ change }', method='POST')
            .row(each='{ parameter, i in item.parameters }')
                .col-md-6
                    .form-group
                        label.control-label { parameter.code } ({ parameter.name })
                        input.form-control(data-id='{ parameter.id }',  type='text', value='{ parameter.value }')

    script(type='text/babel').
        var self = this

        self.mixin('validation')
        self.mixin('permissions')
        self.mixin('change')
        self.item = {}

        self.reload = () => {
            observable.trigger('services-edit', self.item.id)
        }

        self.change = e => {
            let id = e.target.dataset.id
            let value = e.target.value
            self.item.parameters.forEach( (parameter) => {
                if (parameter.id == id) {
                    parameter.value = value
                    return
                }
            })
        }

        self.submit = () => {
            API.request({
                object: 'Service',
                method: 'Save',
                data: self.item,
                success(response) {
                    self.item = response
                    popups.create({title: 'Успех!', text: 'Параметры сохранены!', style: 'popup-success'})
                },
                complete() {
                    self.update()
                }
            })
        }

        observable.on('services-edit', id => {
            var params = {id: id}
            self.error = false
            self.isNew = false
            self.item = {}
            self.loader = true
            self.update()

            API.request({
                object: 'Service',
                method: 'Info',
                data: params,
                success(response) {
                    self.item = response
                },
                complete(){
                    self.loader = false
                    self.update()
                }
            })

        })



