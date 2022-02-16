* eslint-disable no-unused-vars */
/* eslint-disable no-unused-vars */
<template>
  <div>
    <div id="container" />
    <div class="tag1" />
    <ul id="tag">
      <li>哪吒科技</li>
      <li>中国上海</li>
    </ul>
    <el-tag>{{ width }},{{ height }}</el-tag>
    <!-- <div class="input-item">
      <button id="show-obj3d-btn" class="btn" @click="showLayer()">显示图层</button>
      <button id="hide-obj3d-btn" class="btn" @onclick="hideLayer()">隐藏图层</button>
    </div> -->
    <el-row>
      <el-button type="primary" @click="showLayer()">显示图层</el-button>
      <el-button type="primary" @click="hideLayer()">隐藏图层</el-button>
    </el-row>

    <ul v-show="menuShipShow" ref="menuShip" class="ul_menu">
      <li @click="daohang">导航一</li>
      <li @click="alert">alert</li>
      <li class="has-sub" @click="confirm">
        confirm
        <ul v-show="menuShow">
          <li>网页特效原理分析</li>
          <li>响应用户操作</li>
          <li>提示框效果</li>
          <li>事件驱动</li>
          <li>元素属性操作</li>
        </ul>
      </li>
      <li @click="text">text</li>
    </ul>
    <div id="elementmenu">
      <el-menu
        :default-active="activeIndex2"
        mode="horizontal"
        background-color="#fff"
        text-color="#000"
        active-text-color="#409eff"
      >
        <el-menu-item index="1">处理中心</el-menu-item>
        <el-submenu index="2">
          <template slot="title">我的工作台</template>
          <el-checkbox
            v-for="city in cities"
            :key="city"
            :label="city"
            style="display: block; left: 20px"
          >{{ city }}</el-checkbox>
          <el-submenu index="2-4" class="four">
            <template slot="title">选项4</template>
            <el-menu-item index="2-4-1">选项1</el-menu-item>
            <el-menu-item index="2-4-2">选项2</el-menu-item>
            <el-menu-item index="2-4-3">选项3</el-menu-item>
          </el-submenu>
        </el-submenu>
        <el-menu-item index="3">消息中心</el-menu-item>
        <el-menu-item index="4">订单管理</el-menu-item>
      </el-menu>
    </div>

  </div>
</template>
<script type="text/javascript">
import AMapLoader from '@amap/amap-jsapi-loader'

import * as PIXI from 'pixi.js'

import * as THREE from 'three'
import {
  CSS2DObject,
  CSS2DRenderer
} from 'three/examples/jsm/renderers/CSS2DRenderer'
const cityOptions = ['选项一', '选项二', '选项三', '选项四']
export default {
  name: 'Mapview',
  data() {
    return {
      map: null,
      pixiApp: null,
      mainContainer: null,
      raycaster: null,
      mouse: null,
      mycamera: null,
      myscene: null,
      mymeshes: null,
      width: null,
      height: null,
      activeIndex2: '',
      cities: cityOptions,
      polygonIs: false,
      satellite: null,
      satelliteIs: false,
      imageLayer: [],
      menuShipShow: false,
      menuShow: false
    }
  },
  created() {},
  beforeDestroy() {
    this.map.destroy()
  },
  mounted() {
    this.initAMap()
    // 禁用鼠标右键菜单事件【contextmenu】
    document.oncontextmenu = function() {
      return false
    }
    // ul事件委托
  },
  methods: {
    daohang() {
      var result = prompt('请输入要搜索的内容：')
      window.open('https://www.baidu.com/s?wd=' + result)
    },
    alert() {
      alert('alert')
    },
    text() {
      var res = document.getSelection().toString()
      window.open('https://www.baidu.com/s?wd=' + res)
    },
    confirm() {
      alert('confirm')
    },
    initAMap() {
      AMapLoader.load({
        key: '4f84ac154dfef9a263a21c81e3194788', // 设置您的key
        version: '2.0',
        plugins: [
          'AMap.ToolBar',
          'AMap.Driving',
          'AMap.CanvasLayer',
          'AMap.GLCustomLayer'
        ],
        AMapUI: {
          version: '1.1',
          plugins: []
        },
        Loca: {
          version: '2.0'
        }
      })
        .then((AMap) => {
          var lnglat = new AMap.LngLat(121.37, 31.47)
          var imageLayer = new AMap.ImageLayer({
            url: 'https://ae01.alicdn.com/kf/H12aa8b05e0f44c699163854961a0a5faX.png',
            bounds: new AMap.Bounds(
              [121.369765, 31.485106],
              [121.384765, 31.492366]
            ),
            zooms: [15, 21]
          })
          var imageLayer2 = new AMap.ImageLayer({
            url: 'https://amappc.cn-hangzhou.oss-pub.aliyun-inc.com/lbs/static/img/dongwuyuan.jpg',
            bounds: new AMap.Bounds(
              [121.369765, 31.485106],
              [121.384765, 31.492366]
            ),
            zooms: [15, 21]
          })
          var satellite = new AMap.TileLayer.Satellite()
          this.satellite = satellite
          this.imageLayer[0] = imageLayer
          this.imageLayer[1] = imageLayer2
          satellite.hide()
          this.imageLayer[1].hide()
          this.map = new AMap.Map('container', {
            viewMode: '3D',
            zoom: 15, // 初始化地图级别
            center: lnglat,
            resizeEnable: true,
            layers: [AMap.createDefaultLayer(), this.satellite, this.imageLayer[0], this.imageLayer[1]]
          })

          var camera
          var renderer
          var scene
          var meshes = []
          var labelRenderer
          // 数据转换工具
          var customCoords = this.map.customCoords
          // 数据使用转换工具进行转换，这个操作必须要提前执行（在获取镜头参数 函数之前执行），否则将会获得一个错误信息。
          // var data = customCoords.lngLatsToCoords([[121.368578, 31.469916]]);
          var data = customCoords.lngLatsToCoords([[121.37, 31.47]])

          // 创建 GL 图层
          var gllayer = new AMap.GLCustomLayer({
            // 图层的层级
            zIndex: 10,
            // 初始化的操作，创建图层过程中执行一次。
            init: (gl) => {
              // 这里我们的地图模式是 3D，所以创建一个透视相机，相机的参数初始化可以随意设置，因为在 render 函数中，每一帧都需要同步相机参数，因此这里变得不那么重要。
              // 如果你需要 2D 地图（viewMode: '2D'），那么你需要创建一个正交相机
              camera = new THREE.PerspectiveCamera(
                60,
                window.innerWidth / window.innerHeight,
                100,
                1 << 30
              )
              this.mycamera = camera
              function onWindowResize() {
                camera.aspect = window.innerWidth / window.innerHeight
                camera.updateProjectionMatrix()
                renderer.setSize(window.innerWidth, window.innerHeight)
                labelRenderer.setSize(window.innerWidth, window.innerHeight)
              }
              renderer = new THREE.WebGLRenderer({
                context: gl // 地图的 gl 上下文
              })

              // 自动清空画布这里必须设置为 false，否则地图底图将无法显示
              renderer.autoClear = false
              scene = new THREE.Scene()
              this.myscene = scene
              // 环境光照和平行光
              var aLight = new THREE.AmbientLight(0xffffff, 0.3)
              var dLight = new THREE.DirectionalLight(0xffffff, 1)
              dLight.position.set(1000, -100, 900)
              scene.add(dLight)
              scene.add(aLight)

              var texture = new THREE.TextureLoader().load(
                'https://a.amap.com/jsapi_demos/static/demo-center-v2/three.jpeg'
              )
              texture.minFilter = THREE.LinearFilter
              //  这里可以使用 three 的各种材质
              var mat = new THREE.MeshPhongMaterial({
                color: 0xfff0f0,
                depthTest: true,
                transparent: true,
                map: texture
              })
              this.mymeshes = []
              var geo = new THREE.BoxBufferGeometry(1000, 1000, 1000)
              for (let i = 0; i < data.length; i++) {
                const d = data[i]
                var mesh = new THREE.Mesh(geo, mat)

                mesh.position.set(d[0], d[1], 500)
                mesh.testName = i
                meshes.push({
                  mesh,
                  count: i
                })
                this.mymeshes.push(mesh)
                scene.add(mesh)
              }
              var path1 = [
                [121.32, 31.45],
                [121.36, 31.45]
              ]
              var polyline1 = new AMap.Polyline({
                path: path1, // 设置线覆盖物路径
                showDir: true,
                strokeColor: '#3366bb', // 线颜色
                strokeWeight: 10 // 线宽
              })
              // eslint-disable-next-line no-array-constructor
              var polygonArr = new Array() // 多边形覆盖物节点坐标数组
              polygonArr.push([121.35, 31.47])
              polygonArr.push([121.36, 31.47])
              polygonArr.push([121.35, 31.46])
              polygonArr.push([121.34, 31.46])
              var polygon = new AMap.Polygon({
                path: polygonArr, // 设置多边形边界路径
                strokeColor: '#FF33FF', // 线颜色
                strokeOpacity: 0.2, // 线透明度
                strokeWeight: 3, // 线宽
                fillColor: '#1791fc', // 填充色
                fillOpacity: 0.35, // 填充透明度
                zIndex: -1
              })
              var that = this
              polygon.on('mouseover', function(e) {
                e = e || window.event
                e.stopPropagation ? e.stopPropagation() : e.cancelBubble = true
                that.polygonIs = true
              }).on('mouseout', function(e) {
                e = e || window.event
                e.stopPropagation ? e.stopPropagation() : e.cancelBubble = true
                that.polygonIs = false
              })
              this.map.add([polyline1, polygon])
              this.raycaster = new THREE.Raycaster()
              this.mouse = new THREE.Vector2(1, 1)
              const ul = document.getElementById('tag')
              const label = new CSS2DObject(ul)
              labelRenderer = new CSS2DRenderer()
              labelRenderer.setSize(window.innerWidth, window.innerHeight)
              labelRenderer.domElement.style.position = 'absolute'
              // 相对鼠标的相对偏移
              labelRenderer.domElement.style.top = '0px'
              labelRenderer.domElement.style.left = '50'
              // //设置.pointerEvents=none，以免模型标签HTML元素遮挡鼠标选择场景模型
              labelRenderer.domElement.style.pointerEvents = 'none'
              // labelRenderer.domElement.style.zIndex = '0'
              document.querySelector('.tag1').appendChild(labelRenderer.domElement)
              scene.add(label)
              // window.addEventListener('click', this.onMouseClick, false)
              window.addEventListener('resize', onWindowResize, false)
              window.addEventListener('mousemove', this.onMouseMove, false)
              window.addEventListener('mouseup', this.onMouseUp, false)
            },
            render: () => {
              // 这里必须执行！！重新设置 three 的 gl 上下文状态。
              renderer.state.reset()
              var { near, far, fov, up, lookAt, position } =
                customCoords.getCameraParams()

              // 这里的顺序不能颠倒，否则可能会出现绘制卡顿的效果。
              camera.near = near
              camera.far = far
              camera.fov = fov
              camera.position.set(...position)
              camera.up.set(...up)
              camera.lookAt(...lookAt)
              camera.updateProjectionMatrix()
              labelRenderer.render(scene, camera)
              renderer.render(scene, camera)
            }
          })
          this.map.add(gllayer)
          var thatMap = this.map
          // 动画
          function animate() {
            for (let i = 0; i < meshes.length; i++) {
              // eslint-disable-next-line prefer-const
              let { mesh, count } = meshes[i]
              count += 1
              mesh.rotateZ((count / 180) * Math.PI)
            }
            thatMap.render()
            requestAnimationFrame(animate)
          }
          animate()
        })
        .catch((e) => {
          console.log(e)
        })
    },
    initPixi() {
      this.pixiApp = new PIXI.Application({
        width: 1800,
        height: 1800,
        transparent: true,
        autoStart: false,
        forceCanvas: true
      })

      this.pixiApp.renderer.view.style.position = 'absolute'
      this.pixiApp.renderer.view.style.display = 'block'

      this.mainContainer = new PIXI.Container()
      this.pixiApp.stage.addChild(this.mainContainer)
    },
    onMouseClick(event) {
      // 通过鼠标点击的位置计算出raycaster所需要的点的位置，以屏幕中心为原点，值的范围为-1到1.
      this.mouse.x = (event.clientX / window.innerWidth) * 2 - 1
      this.mouse.y = -(event.clientY / window.innerHeight) * 2 + 1

      // 通过鼠标点的位置和当前相机的矩阵计算出raycaster
      this.raycaster.setFromCamera(this.mouse, this.mycamera)

      // 获取raycaster直线和所有模型相交的数组集合
      var intersects = this.raycaster.intersectObjects(this.myscene.children)
      console.log(intersects[0].object.testName)

      console.log(intersects[0].point)
      alert(intersects[0].object.testName)
    },
    onMouseMove(e) {
      e.preventDefault()

      // 通过鼠标点的位置和当前相机的矩阵计算出raycaster
      this.raycaster.setFromCamera(this.mouse, this.mycamera)
      const container = document.querySelector('#container')
      const getBoundingClientRect = container.getBoundingClientRect()
      this.mouse.x = ((e.clientX - getBoundingClientRect.left) / container.offsetWidth) * 2 - 1
      this.mouse.y = -((e.clientY - getBoundingClientRect.top) / container.offsetHeight) * 2 + 1
      // 获取raycaster直线和所有模型相交的数组集合
      var intersects = this.raycaster.intersectObjects(this.myscene.children)
      const a = document.querySelector('.el-tag')
      const disX = e.clientX
      const disY = e.clientY
      if (intersects[0] || this.polygonIs) {
        a.style.left = disX + 5 + 'px'
        a.style.top = disY + 'px'
        a.style.display = 'block'
        this.width = disX
        this.height = disY
      } else {
        a.style.display = 'none'
      }
    },
    showLayer() {
      this.satellite.show()
      this.satelliteIs = true
      this.imageLayer[0].hide()
      this.imageLayer[1].show()
    },
    hideLayer() {
      this.satellite.hide()
      this.satelliteIs = false
      this.imageLayer[0].show()
      this.imageLayer[1].hide()
    },
    onMouseUp(e) {
      e.preventDefault()
      const container = document.querySelector('#container')
      const getBoundingClientRect = container.getBoundingClientRect()
      this.mouse.x = ((e.clientX - getBoundingClientRect.left) / container.offsetWidth) * 2 - 1
      this.mouse.y = -((e.clientY - getBoundingClientRect.top) / container.offsetHeight) * 2 + 1
      // 通过鼠标点的位置和当前相机的矩阵计算出raycaster
      this.raycaster.setFromCamera(this.mouse, this.mycamera)

      // 获取raycaster直线和所有模型相交的数组集合
      var intersects = this.raycaster.intersectObjects(this.myscene.children)
      function hasClass(element, className) {
        return new RegExp('(^|\\s)' + className + '($|\\s)').test(
          element.className
        )
      }
      const ul = this.$refs.menuShip
      if (e.button === 2 && (intersects[0] || this.polygonIs)) {
        //     // 设置菜单位置
        this.menuShipShow = true
        ul.style.left = e.clientX + 5 + 'px'
        ul.style.top = e.clientY + 5 + 'px'
        ul.onmouseover = function(event) {
          var target = event.target
          if (hasClass(target, 'has-sub')) {
            const child = target.querySelector('ul')
            child.style.left = e.clientX + 150 + 'px'
            child.style.top = e.clientY + target.offsetTop + 'px'
          }
        }
      } else {
        this.menuShipShow = false
      }
    }
  }
}
</script>

<style scoped>
/* .home_div {
  padding: 0px;
  margin: 0px;
  width: 100%;
  height: 100%;
  position: relative;
} */
#container {
  padding: 0px;
  margin: 0px;
  width: 100%;
  height: 100%;
  position: absolute;
}
/* .map_title {
  position: absolute;
  z-index: 1;
  width: 100%;
  height: 50px;
  background-color: rgba(27, 25, 27, 0.884);
} */
h3 {
  position: absolute;
  left: 10px;
  z-index: 2;
  color: white;
}
.el-tag {
  position: fixed;
  display: none;
  pointer-events: none;
  min-width: 80px;
  z-index: 1;
  font-size: 15px;
  text-align: center;
  line-height: 20px;
  color: #303133;
  border-radius: 2px;
  border: 1px solid #dcdfe6;
  background: #ffffff;
  overflow: hidden;
  height: 20px;
  font-family: "Helvetica Neue", Helvetica, "PingFang SC", "Hiragino Sans GB",
    "Microsoft YaHei", "微软雅黑", Arial, sans-serif;
}
* {
  padding: 0;
  margin: 0;
}

.ul_menu,
.ul_menu ul {
  min-width: 150px;
  list-style: none;
  background: #ffffff;
  border: 1px solid #dcdfe6;
  position: fixed;
  z-index: 1;
}
.ul_menu li {
  height: 25px;
  padding: 0 10px;
  border-bottom: 1px solid #e4e7ed;
  line-height: 25px;
  cursor: pointer;
  transition: all 0.3s;
  font-family: "Helvetica Neue", Helvetica, "PingFang SC", "Hiragino Sans GB",
    "Microsoft YaHei", "微软雅黑", Arial, sans-serif;
  font-size: 13px;
  white-space: nowrap;
  color: #000;
}
.ul_menu li:last-of-type {
  border-bottom: 0 none;
}
.ul_menu li:hover {
  background: #409eff;
  color: #fff;
}
.ul_menu li.has-sub:hover > ul {
  display: block !important
}
.ul_menu li.has-sub {
  background-image: url(https://pandoraui.github.io/learning-javascript/lesson6/img/arrow.png);
  background-repeat: no-repeat;
  background-position: right 9px;
}
/* #container {
  height: 630px;
} */
/* #elementmenu {
  overflow-x: hidden;
} */
.el-menu {
  display: flex;
  position: absolute;
  top: 20px;
  left: 50%;
  height: 40px;
}
 .el-menu--horizontal > .el-submenu /deep/ .el-submenu__title {
  height: 40px;
  line-height: 40px;
  padding: 0 20px;
}

.el-menu--horizontal > .el-menu-item {
  height: 40px;
  line-height: 40px;
  padding: 0 30px;
}
.el-menu .el-submenu /deep/ .el-submenu__title {
  padding: 0 20px;
}
ul#tag {
  padding: 4px 10px;
  color: #808080;
  text-shadow: 0 1px white, 1px 0 white, -1px 0 white, 0 -1px white;
  font-size: 16px;
  position: absolute;
  border-radius: 5px;
  pointer-events: none;
  list-style: none;
}
</style>

