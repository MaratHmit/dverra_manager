| import './import-file.tag'
| import './import-fields.tag'
| import './import-settings.tag'
| import './import-result.tag'
| import './profile-modal.tag'

import
    h3 Импорт из XLSX, XLS, CSV
    loader(if='{ loader }')
    h4(if='{ step == "file" }') Шаг 1. Файл данных
    h4(if='{ step == "fields" }') Шаг 2. Структура данных
    h4(if='{ step == "settings" }') Шаг 3. Настройки импорта
    h4(if='{ step == "result" }') Результат импорта

    form(onchange='{ change }', onkeyup='{ change }')
        import-file(if='{ step == "file" }')
        import-fields(if='{ step == "fields" }')
        import-settings(if='{ step == "settings" }')
        import-result(if='{ step == "result" }')

    script(type='text/babel').
        var self = this

        self.item = {
            encoding: "auto",
            separator: "auto",
            skipCountRows: 1,
        }

        self.mixin('change')

        self.loader = true
        self.step = "file"
        self.fileSelected = false
        self.groups = []
        self.brands = []
        self.profiles = []
        self.importResult = {}

        self.changeFile = (e) => {
            self.item.filename = e.target.files[0].name
            self.fileSelected = true
            self.update()
        }

        self.loadFile = () => {
            let formData = new FormData()
            let importForm = self.tags["import-file"]
            let target = importForm.file
            let oldItem = self.item

            if (self.item.idProfile)
                formData.append('idProfile', self.item.idProfile)
            formData.append('separator', self.item.separator)
            formData.append('encoding', self.item.encoding)
            formData.append('filename', target.files[0].name)
            formData.append('skipCountRows', self.item.skipCountRows)
            formData.append('file', target.files[0], target.files[0].name)
            self.loader = false
            self.update()

            API.upload({
                object: 'Import',
                data: formData,
                success(response) {
                    self.step = "fields"
                    self.item = response
                    for (let key in oldItem)
                        if (!(key in self.item))
                            self.item[key] = oldItem[key]
                    if (!self.item.keyField)
                        self.item.keyField = "article"
                    if (!self.item.folderImages)
                        self.item.folderImages = "/"
                },
                complete() {
                    self.loader = false
                    self.update()
                }
            })
        }

        self.setSettings = () => {
            self.step = "settings"
            self.update()
        }

        self.back = () => {
            if (self.step == "fields")
                self.step = "file"
            if (self.step == "settings")
                self.step = "fields"
            self.update()
        }

        self.exec = () => {
            self.loader = true
            self.update()
            let item = self.item

            API.request({
                object: 'Import',
                method: 'Exec',
                data: self.item,
                success(response) {
                    self.importResult = response
                },
                complete() {
                    self.step = "result"
                    self.loader = false
                    self.update()
                    modals.create('profile-modal', {
                        type: 'modal-primary',
                        item,
                        submit() {
                            let _this = this
                            let rules = { profileName: 'empty' }
                            _this.error = _this.validation.validate(_this.item, rules)

                            if (!_this.error) {
                                API.request({
                                    object: 'Import',
                                    method: 'Save',
                                    data: _this.item,
                                    success(response) {
                                        popups.create({title: 'Успех!', text: 'Профиль сохранен!', style: 'popup-success'})
                                        _this.modalHide()
                                    },
                                })
                            }
                        }
                    })
                }
            })
        }

        self.catalog = () => {
            observable.trigger('products-reload')
            riot.route(`/products`)
        }

        self.newImport = () => {
            self.item = {
                encoding: "auto",
                separator: "auto",
                skipCountRows: 1,
            }

            self.loader = true
            self.step = "file"
            self.loadProfiles()
            self.update()
        }

        self.selectProfile = (e) => {
            let idProfile = e.target.value
            self.profiles.forEach(function(item) {
                if (item.id == idProfile) {
                    let fileName = self.item.filename
                    self.item = JSON.parse(item.settings)
                    self.item.filename = fileName
                    self.item.idProfile = idProfile
                    self.item.profileName = item.name
                    self.update()
                    return
                }
            })
        }

        self.loadGroups = () => {
            let data = { sortBy: "name", sortOrder: "asc" }
            API.request({
                object: 'Category',
                method: 'Fetch',
                data: data,
                success(response) {
                    self.groups = response.items
                }
            })
        }

        self.loadBrands = () => {
            let data = { sortBy: "name", sortOrder: "asc", limit: 1000 }
            API.request({
                object: 'Brand',
                data: data,
                method: 'Fetch',
                success(response) {
                    self.brands = response.items
                }
            })
        }

        self.loadProfiles = () => {
            API.request({
                object: 'ImportProfile',
                method: 'Fetch',
                success(response) {
                    self.profiles = response.items
                },
                complete() {
                    self.loader = false
                    self.update()
                }
            })
        }

        self.loadGroups()
        self.loadBrands()

        self.on('mount', () => {
            self.newImport()
        })

        observable.on('import-start', () => {
            self.newImport()
        })