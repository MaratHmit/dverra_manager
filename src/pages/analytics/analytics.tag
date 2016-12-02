| import './analytics-statictics.tag'
| import 'components/chart/chart.tag'
| import moment from 'moment'
analytics
    loader(if='{ loader }')
    div(hide='{ loader }')
        .row
            .col-md-12
                .well.well-sm
                    .form-inline
                        .form-group
                            button.btn.btn-success(type='button', onclick='{ reload }')
                                i.fa.fa-refresh
                                |  Обновить
                        .form-group
                            label.control-label Выберите период
                            datetime-picker.form-control(name='startDate', format='DD.MM.YYYY')
                            |  —
                            datetime-picker.form-control(name='endDate', format='DD.MM.YYYY')

        .row
            .col-md-12
                analytics-statictics(value='{ value }')

        .row
            .col-md-12
                ul.nav.nav-tabs
                    li(each='{ tabs }', class='{ active: name == tab }')
                        a(href='#', onclick='{ tabClick }') { title }

        .row(if='{ tab == "funnel" }')
            .col-md-6.col-md-offset-3
                loader(if='{ tabLoader == "funnel" }')
                chart(type='funnel', data='{ createChartFunnelData(value.funnel) }', options='{ chartFunnelOptions }')

        .row(if='{ tab == "statisticsOrders" }')
            .col-md-12
                loader(if='{ tabLoader == "statisticsOrders" }')
                chart(type='bar', data='{ createChartStatisticsData(value.statisticsOrders) }', options='{ chartFunnelOptions }')

    script(type='text/babel').
        var self = this

        self.loader = false
        self.value = {}

        self.tab = 'funnel'
        self.tabLoader = 'funnel'
        self.tabs = [
            {title: 'Воронка', name: 'funnel'},
            {title: 'Статистика', name: 'statisticsOrders'},
        ]

        self.tabClick = e => {
            if (e && e.item && e.item.name) {
                if (self.tab === e.item.name) return
                self.tab = self.tabLoader = e.item.name
            }

            let data = {
                startDate: self.tags.startDate.root.value
                    ? moment(self.tags.startDate.root.value, 'DD.MM.YYYY').format('YYYY-MM-DD')
                    : '',
                endDate: self.tags.endDate.root.value
                    ? moment(self.tags.endDate.root.value, 'DD.MM.YYYY').format('YYYY-MM-DD')
                    : ''
            }

            API.request({
                object: 'Analytics',
                method: 'Info',
                data: {
                    ...data,
                    data: self.tab
                },
                success(response) {
                    self.value = { ...self.value, ...response }
                    self.tabLoader = ''
                    self.update()
                }
            })
        }

        self.createChartFunnelData = data => {
            if (!(data instanceof Array)) return

            var result = {
                labels: [],
                datasets: [{
                    data: [],
                    backgroundColor: [],
                    borderWidth: 1
                }]
            }

            data.forEach((value, index, array) => {
                result.labels.push(value.Title)
                result.datasets[0].data.push(value.Value)
                result.datasets[0].backgroundColor.push(value.Color)
            })

            return result
        }

        self.createChartStatisticsData = data => {
            let result = {
                labels: [],
                datasets: [{
                    label: 'Статистика',
                    data: [],
                    backgroundColor: 'rgba(34, 139, 34, 0.3)',
                    borderColor: 'rgba(34, 139, 34, 1)',
                    borderWidth: 1
                }]
            }

            data.forEach((value, index, array) => {
                let dateOrder = moment(value.dateOrder, 'YYYY-MM-DD').format('DD.MM.YYYY')
                result.labels.push(dateOrder)
                result.datasets[0].data.push(value.sum)
            })

            return result
        }

        self.chartFunnelOptions = {}

        self.reload = () => {
            let data = {
                startDate: self.tags.startDate.root.value
                    ? moment(self.tags.startDate.root.value, 'DD.MM.YYYY').format('YYYY-MM-DD')
                    : '',
                endDate: self.tags.endDate.root.value
                    ? moment(self.tags.endDate.root.value, 'DD.MM.YYYY').format('YYYY-MM-DD')
                    : ''
            }

            self.loader = true
            self.update()

            if (self.root.parentNode) {
                API.request({
                    object: 'Analytics',
                    method: 'Info',
                    data: data,
                    success(response) {
                        self.value = { ...self.value, ...response }
                        self.update()
                    },
                    complete() {
                        self.loader = false
                        self.update()
                    }
                })
            }

            self.tabClick()
        }


        self.one('updated', () => {
            self.tags.startDate.root.value = moment().startOf('month').format('DD.MM.YYYY')
            self.tags.endDate.root.value = moment().format('DD.MM.YYYY')
            self.reload()
        })

        self.on('mount', () => {
            riot.route.exec()
        })

