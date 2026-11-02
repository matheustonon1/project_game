<div align="center">

<img src="versao-nova/assets/kitchen-kunai-logo.png" alt="Logo do Kitchen Kunai" width="280">

<p>
  <img alt="Lua" src="https://img.shields.io/badge/Lua-2C2D72?style=flat-square&logo=lua&logoColor=white">
  <img alt="LÖVE 11.5" src="https://img.shields.io/badge/L%C3%96VE-11.5-E74A99?style=flat-square">
  <img alt="Duas versões" src="https://img.shields.io/badge/vers%C3%B5es-2-F97316?style=flat-square">
</p>

</div>

**Kitchen Kunai** é um jogo em que um ninja precisa ganhar peso dentro de um dojo: comer as comidas boas, fugir das estragadas e aguentar os lutadores de sumô.

A ideia é inspirada no minijogo [ConSumo](https://youtu.be/ershQOeigTw), do jogo *Bully*. O projeto foi desenvolvido para a disciplina de Multimídia, do curso de Engenharia da Computação do Centro Universitário Regional de Espírito Santo do Pinhal.

## Duas versões

Este repositório guarda o jogo como foi entregue na disciplina e uma versão com o visual refeito depois.

| | [Versão original](versao-original) | [Versão nova](versao-nova) |
|---|---|---|
| **Para que serve** | O trabalho como foi entregue | A melhor forma de jogar hoje |
| **Como rodar** | `KitchenKunai.exe` ou LÖVE | LÖVE 11.5 |
| **Menus** | Telas com um comando em texto | Menus com opções, como jogar e pausa |
| **Colisão com lutador** | Empurrão instantâneo | Arremesso animado, girando no ar |
| **Fim de jogo** | Só o aviso de game over | Peso, recorde, comidas, tempo e título |
| **Recorde** | Salvo, mas não carregado ao abrir | Salvo e mostrado no menu |

## Antes e depois

<table>
  <tr>
    <th>Original</th>
    <th>Nova</th>
  </tr>
  <tr>
    <td><img src="versao-original/docs/capturas/menu.png" alt="Menu da versão original"></td>
    <td><img src="versao-nova/docs/capturas/menu.png" alt="Menu da versão nova, com opções e recorde"></td>
  </tr>
  <tr>
    <td><img src="versao-original/docs/capturas/jogo.png" alt="Partida na versão original"></td>
    <td><img src="versao-nova/docs/capturas/jogo.png" alt="Partida na versão nova, com a HUD refeita"></td>
  </tr>
  <tr>
    <td><img src="versao-original/docs/capturas/pausa.png" alt="Pausa na versão original"></td>
    <td><img src="versao-nova/docs/capturas/pausa.png" alt="Painel de pausa da versão nova"></td>
  </tr>
  <tr>
    <td><img src="versao-original/docs/capturas/gameover.png" alt="Fim de jogo na versão original"></td>
    <td><img src="versao-nova/docs/capturas/gameover.png" alt="Fim de jogo da versão nova, com estatísticas"></td>
  </tr>
</table>

## Como jogar

Instale o [LÖVE 11.5](https://love2d.org/) e rode a versão que preferir a partir da raiz do repositório:

```bash
love versao-nova
```

```bash
love versao-original
```

No Windows, a versão original também abre direto por `versao-original/Executável/KitchenKunai.exe`.

Os controles e as regras de cada versão estão no README da pasta: [versão original](versao-original#como-jogar) e [versão nova](versao-nova#como-jogar).
