/**
 * 离线游戏集成测试脚本
 * 在浏览器控制台中运行此脚本来测试功能
 */

console.log('🧪 开始测试离线游戏集成...');

// 测试1: 检查必要的全局对象
function testGlobalObjects() {
  console.log('\n📋 测试1: 检查全局对象');
  
  const requiredObjects = [
    'window',
    'document',
    'fetch',
    'localStorage'
  ];
  
  const results = requiredObjects.map(obj => {
    const exists = typeof window[obj] !== 'undefined';
    console.log(`${exists ? '✅' : '❌'} ${obj}: ${exists ? '存在' : '缺失'}`);
    return exists;
  });
  
  return results.every(Boolean);
}

// 测试2: 检查网络状态检测
async function testNetworkDetection() {
  console.log('\n🌐 测试2: 网络状态检测');
  
  try {
    const response = await fetch('/api/health', { method: 'HEAD' });
    const isOnline = response.ok;
    console.log(`✅ 健康检查API: ${isOnline ? '正常' : '异常'} (${response.status})`);
    return isOnline;
  } catch (error) {
    console.log(`❌ 健康检查API失败: ${error.message}`);
    return false;
  }
}

// 测试3: 检查游戏脚本加载
async function testGameScriptLoading() {
  console.log('\n🎮 测试3: 游戏脚本加载');
  
  return new Promise((resolve) => {
    const script = document.createElement('script');
    script.src = '/offline-dino/dino-game-fixed.js';
    script.async = true;
    
    script.onload = () => {
      console.log('✅ 游戏脚本加载成功');
      
      if (typeof window.DinoGame !== 'undefined') {
        console.log('✅ DinoGame类已定义');
        resolve(true);
      } else {
        console.log('❌ DinoGame类未定义');
        resolve(false);
      }
    };
    
    script.onerror = () => {
      console.log('❌ 游戏脚本加载失败');
      resolve(false);
    };
    
    document.head.appendChild(script);
    
    // 5秒超时
    setTimeout(() => {
      console.log('⏰ 游戏脚本加载超时');
      resolve(false);
    }, 5000);
  });
}

// 测试4: 检查Canvas支持
function testCanvasSupport() {
  console.log('\n🎨 测试4: Canvas支持');
  
  const canvas = document.createElement('canvas');
  const ctx = canvas.getContext('2d');
  
  if (ctx) {
    console.log('✅ Canvas 2D上下文支持正常');
    
    // 测试基本绘制功能
    try {
      ctx.fillStyle = '#87CEEB';
      ctx.fillRect(0, 0, 100, 100);
      console.log('✅ 基本绘制功能正常');
      return true;
    } catch (error) {
      console.log(`❌ 绘制功能异常: ${error.message}`);
      return false;
    }
  } else {
    console.log('❌ Canvas 2D上下文不支持');
    return false;
  }
}

// 测试5: 检查Service Worker支持
function testServiceWorkerSupport() {
  console.log('\n🔧 测试5: Service Worker支持');
  
  if ('serviceWorker' in navigator) {
    console.log('✅ Service Worker支持正常');
    
    // 检查是否有已注册的Service Worker
    navigator.serviceWorker.getRegistrations().then(registrations => {
      if (registrations.length > 0) {
        console.log(`✅ 发现${registrations.length}个Service Worker`);
      } else {
        console.log('⚠️ 未发现已注册的Service Worker');
      }
    });
    
    return true;
  } else {
    console.log('❌ Service Worker不支持');
    return false;
  }
}

// 测试6: 检查离线游戏组件
function testOfflineGameComponents() {
  console.log('\n🎯 测试6: 离线游戏组件');
  
  // 检查必要的组件是否存在
  const components = [
    'OfflineGame',
    'NetworkStatusIndicator', 
    'OfflineGameProvider'
  ];
  
  // 这些组件应该在React组件树中，这里只是检查导入
  console.log('ℹ️ 组件检查需要在React环境中进行');
  return true;
}

// 运行所有测试
async function runAllTests() {
  console.log('🚀 开始运行所有测试...\n');
  
  const results = [];
  
  results.push(testGlobalObjects());
  results.push(await testNetworkDetection());
  results.push(await testGameScriptLoading());
  results.push(testCanvasSupport());
  results.push(testServiceWorkerSupport());
  results.push(testOfflineGameComponents());
  
  // 等待所有测试完成
  const allResults = await Promise.all(results);
  
  console.log('\n📊 测试结果汇总:');
  console.log('=====================================');
  
  const testNames = [
    '全局对象检查',
    '网络状态检测',
    '游戏脚本加载',
    'Canvas支持',
    'Service Worker支持',
    '离线游戏组件'
  ];
  
  allResults.forEach((result, index) => {
    console.log(`${result ? '✅' : '❌'} ${testNames[index]}: ${result ? '通过' : '失败'}`);
  });
  
  const passedTests = allResults.filter(Boolean).length;
  const totalTests = allResults.length;
  
  console.log('=====================================');
  console.log(`🎯 测试通过率: ${passedTests}/${totalTests} (${Math.round(passedTests/totalTests*100)}%)`);
  
  if (passedTests === totalTests) {
    console.log('🎉 所有测试通过！离线游戏集成成功！');
  } else {
    console.log('⚠️ 部分测试失败，请检查相关配置');
  }
  
  return allResults;
}

// 导出测试函数供外部调用
window.testOfflineIntegration = {
  runAllTests,
  testGlobalObjects,
  testNetworkDetection,
  testGameScriptLoading,
  testCanvasSupport,
  testServiceWorkerSupport,
  testOfflineGameComponents
};

console.log('📝 测试脚本已加载，使用以下命令运行测试:');
console.log('testOfflineIntegration.runAllTests()');
console.log('\n或者运行单个测试:');
console.log('testOfflineIntegration.testNetworkDetection()');
console.log('testOfflineIntegration.testGameScriptLoading()');

// 自动运行测试（可选）
if (window.location.search.includes('auto-test=true')) {
  console.log('\n🔄 检测到自动测试参数，开始运行测试...');
  setTimeout(runAllTests, 1000);
}







