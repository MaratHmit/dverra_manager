| import 'components/loader.tag'
| import './geo-zones-region-edit-modal.tag'

geo-zones-edit
    loader(if='{ loader }')
    virtual(hide='{ loader }')
        .btn-group
            a.btn.btn-default(href='#settings/geo-zones') #[i.fa.fa-chevron-left]
            button.btn.btn-default(onclick='{ submit }', type='button')
                i.fa.fa-floppy-o
                |  Сохранить
            button.btn.btn-default(if='{ !isNew }', onclick='{ reload }', title='Обновить', type='button')
                i.fa.fa-refresh
        .h4 { 'Редактирование зоны' }

        form(action='', onchange='{ change }', onkeyup='{ change }', method='POST')
            .row
                .col-md-6: .form-group(class='{ has-error: error.name }')
                    label.control-label Наименование
                    input.form-control(name='name', type='text', value='{ item.name }')
                    .help-block { error.name }
            .row
                .col-md-6: catalog-static(name='{ regions }', add='{ addRegion }',
                    cols='{ cols }', rows='{ item.regions }', handlers='{ handlers }')
                    #{'yield'}(to='body')
                        datatable-cell(name='id') { row.id }
                        datatable-cell(name='region') { row.region }
                        datatable-cell(name='city') { row.city }
                        datatable-cell(name='area') { row.area }

    script(type='text/babel').

        var self = this

        self.mixin('validation')
        self.mixin('change')

        self.rules = {
            name: 'empty',
        }

        self.cols = [
            {name: 'id', value: '#'},
            {name: 'region', value: 'Регион'},
            {name: 'city', value: 'Город'},
            {name: 'area', value: 'Округ'},
        ]

        self.addRegion = () => {
            modals.create('geo-zones-region-edit-modal', {
                type: 'modal-primary',
                isNew: true,
                submit() {
                    var _this = this

                }
            })
        }

        observable.on('geo-zones-edit', id => {
            var params = {id: id}
            self.error = false
            self.loader = true
            API.request({
                object: 'GeoZone',
                method: 'Info',
                data: params,
                success: (response, xhr) => {
                    self.item = response
                    self.loader = false
                    self.update()
                },
                error(response) {
                    self.item = {}
                    self.loader = false
                    self.update()
                }
            })
        })

        self.submit = e => {
            var params = self.item
            self.error = self.validation.validate(params, self.rules)

            if (!self.error) {
                if (self.item && self.item.hash && self.item.hash.trim() === '')
                delete self.item.hash

                API.request({
                    object: 'GeoZone',
                    method: 'Save',
                    data: params,
                    success(response) {
                        popups.create({title: 'Успех!', text: 'Изменения сохранены!', style: 'popup-success'})
                        self.item = response
                        self.update()
                        observable.trigger('geo-zones-reload')
                    }
                })
            }
        }


