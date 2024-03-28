<template>
  <section>
    <div
        class="relative bg-gradient-to-r from-purple-600 to-blue-600 h-screen text-white overflow-hidden">
      <div class="absolute inset-0">
        <img
          :src="images.banner"
          alt="Background Image"
          class="object-cover object-center w-full h-full"
        />
        <div class="absolute inset-0 bg-black opacity-50"></div>
      </div>

      <div class="relative z-10 flex flex-col justify-center items-center h-full text-center">
        <h1 class="text-3xl md:text-4xl lg:text-5xl font-bold leading-tight mb-4">
          Warcraft II Lives on!
        </h1>
        <h2 class="text-2xl mt-3">Downloads</h2>
        <div class="flex flex-col md:flex-row justify-center md:space-x-4 mt-1">
          <a
            :href="links.war2combatLink"
            class="mt-3 bg-slate-300 text-gray-900 hover:bg-slate-400 py-2 px-6 rounded-full text-lg font-semibold transition duration-300 ease-in-out transform hover:scale-105 hover:shadow-lg"
          >Warcraft II Combat Edition</a>
          <a
            :href="links.battlenetGatewayEditorLink"
            class="mt-3 bg-slate-300 text-gray-900 hover:bg-slate-400 py-2 px-6 rounded-full text-lg font-semibold transition duration-300 ease-in-out transform hover:scale-105 hover:shadow-lg"
          >Battlenet Gateway Editor</a>
        </div>
        <div class="">
          <h2 class="text-3xl max-w-30 mx-auto mt-4 p-2 rounded-md">Join Our Server</h2>
          <div class="bg-slate-700 border-[1px] rounded-md p-2 text-2xl text-left">
            <p><span class="text-slate-300">NAME:</span> J-BNET</p>
            <p><span class="text-slate-300">IP:</span> {{ info.serverIp }}</p>
            <p><span class="text-slate-300">Zone:</span> {{ info.serverZone }}</p>
          </div>
        </div>
      </div>
    </div>
  </section>
</template>

<script setup>
const info = {
  serverIp: '143.244.152.50',
  serverZone: '0'
}
const images = {
  banner: 'https://images.gog-statics.com/49aec8449b3c9ef7746a3df7c4614dd0cd2402ae24416360b5828e63fe327125_bg_crop_1920x655.jpg'
}
const links = {
  war2combatLink: 'https://downloads.warcraft2.online/war2/War2Combat46_en_full.exe',
  battlenetGatewayEditorLink: 'https://downloads.warcraft2.online/war2/Fixes%20&%20Patches/Registry/BNGatewayEditor.zip'
}

</script>
