#!/usr/bin/env bash
# ==============================================================================
# Gerenciador .DEB (Exclusivo via Terminal / CLI)
# Foco: Listagem e Desinstalação Permanente (Purge completo + Dados do Usuário)
# ==============================================================================

set -euo pipefail

# Cores
VM='\033[1;31m'   # Vermelho
VD='\033[1;32m'   # Verde
AM='\033[1;33m'   # Amarelo
AZ='\033[1;34m'   # Azul
CI='\033[1;36m'   # Ciano
NG='\033[1m'      # Negrito
SC='\033[0m'      # Sem cor

limpar() { clear 2>/dev/null || true; }

# Obtém pacotes .deb locais (sem repositório remoto) usando apenas apt/dpkg
obter_pacotes_deb() {
    local pkg version desc
    for pkg in $(apt list --installed 2>/dev/null | grep ',local]' | cut -d'/' -f1); do
        version=$(dpkg-query -W -f='${Version}' "$pkg" 2>/dev/null || echo "?")
        desc=$(dpkg-query -s "$pkg" 2>/dev/null | sed -n '/^Description:/{s/^Description: *//p;q}')
        if [[ -z "$desc" ]]; then
            desc=$(dpkg-query -s "$pkg" 2>/dev/null | sed -n '/^Description:/{n;s/^ *//p;q}')
        fi
        echo "${pkg}|${version}|${desc:-$pkg}"
    done
}

# Localiza diretórios e arquivos residuais do aplicativo na home do usuário (~/.config, ~/.local/share, ~/.cache, ~/.<app>)
encontrar_dados_usuario() {
    local app="$1"
    local achados=()

    # Busca em locais comuns do XDG
    for base in "$HOME/.config" "$HOME/.local/share" "$HOME/.cache"; do
        if [[ -d "$base" ]]; then
            while IFS= read -r dir; do
                [[ -n "$dir" ]] && achados+=("$dir")
            done < <(find "$base" -mindepth 1 -maxdepth 1 -iname "*${app}*" 2>/dev/null || true)
        fi
    done

    # Busca por diretórios ocultos diretamente na home (ex: ~/.obsidian ou ~/.pureref)
    while IFS= read -r dir; do
        [[ -n "$dir" ]] && achados+=("$dir")
    done < <(find "$HOME" -mindepth 1 -maxdepth 1 -iname ".${app}*" 2>/dev/null || true)

    # Imprime lista única
    if ((${#achados[@]} > 0)); then
        printf "%s\n" "${achados[@]}" | sort -u
    fi
}

# Listar pacotes .deb instalados
listar_pacotes() {
    limpar
    echo -e "${AZ}${NG}======================================================================${SC}"
    echo -e "${AZ}${NG}          APLICATIVOS INSTALADOS MANUALMENTE VIA .DEB                 ${SC}"
    echo -e "${AZ}${NG}======================================================================${SC}\n"

    local raw
    raw=$(obter_pacotes_deb)

    if [[ -z "$raw" ]]; then
        echo -e "${AM}Nenhum aplicativo instalado manualmente via .deb foi encontrado.${SC}\n"
    else
        printf "${NG}%-4s %-26s %-16s %-30s${SC}\n" "Nº" "PACOTE" "VERSÃO" "DESCRIÇÃO"
        echo "----------------------------------------------------------------------"

        local i=1
        while IFS='|' read -r nome versao desc; do
            [[ -z "$nome" ]] && continue
            ((${#desc} > 38)) && desc="${desc:0:35}..."
            printf "%-4d ${CI}%-26s${SC} %-16s %-30s\n" "$i" "$nome" "$versao" "$desc"
            ((i++))
        done <<< "$raw"

        echo -e "\n${VD}Total de pacotes encontrados: $((i - 1))${SC}"
    fi

    echo ""
    echo -e "----------------------------------------------------------------------"
    echo -e "  ${CI}m)${SC} Voltar ao menu principal"
    echo -e "  ${AM}0)${SC} Sair"
    echo ""
    read -rp "Opção: " opt || true
    case "$opt" in
        0|q|Q) sair ;;
        *)     return 0 ;;
    esac
}

# Desinstalar pacote permanentemente (Purge + Limpeza de dados do usuário)
desinstalar_pacote() {
    limpar
    echo -e "${VM}${NG}======================================================================${SC}"
    echo -e "${VM}${NG}              DESINSTALAR PROGRAMA .DEB PERMANENTEMENTE               ${SC}"
    echo -e "${VM}${NG}======================================================================${SC}\n"

    local raw
    raw=$(obter_pacotes_deb)

    if [[ -z "$raw" ]]; then
        echo -e "${AM}Nenhum aplicativo instalado manualmente via .deb foi encontrado.${SC}\n"
        echo -e "----------------------------------------------------------------------"
        echo -e "  ${CI}m)${SC} Voltar ao menu principal"
        echo -e "  ${AM}0)${SC} Sair"
        echo ""
        read -rp "Opção: " opt || true
        case "$opt" in
            0|q|Q) sair ;;
            *)     return 0 ;;
        esac
        return 0
    fi

    local nomes=() versoes=()

    printf "${NG}%-4s %-26s %-16s %-30s${SC}\n" "Nº" "PACOTE" "VERSÃO" "DESCRIÇÃO"
    echo "----------------------------------------------------------------------"

    local idx=1
    while IFS='|' read -r nome versao desc; do
        [[ -z "$nome" ]] && continue
        nomes+=("$nome")
        versoes+=("$versao")
        local desc_curta="$desc"
        ((${#desc_curta} > 38)) && desc_curta="${desc_curta:0:35}..."
        printf "%-4d ${CI}%-26s${SC} %-16s %-30s\n" "$idx" "$nome" "$versao" "$desc_curta"
        ((idx++))
    done <<< "$raw"

    local total="${#nomes[@]}"
    echo ""
    echo -e "----------------------------------------------------------------------"
    echo -e "  ${AM}Digite o número (1-$total) do programa para desinstalar${SC}"
    echo -e "  ${CI}m)${SC} Voltar ao menu principal"
    echo -e "  ${AM}0)${SC} Sair"
    echo ""
    read -rp "Opção: " escolha || true

    case "$escolha" in
        0|q|Q) sair ;;
        m|M)   return 0 ;;
    esac

    if [[ ! "$escolha" =~ ^[0-9]+$ ]] || ((escolha < 1 || escolha > total)); then
        echo -e "\n${VM}Opção inválida!${SC}"
        sleep 1
        return 0
    fi

    local pos=$((escolha - 1))
    local alvo="${nomes[$pos]}"
    local versao_alvo="${versoes[$pos]}"

    # AVISO CRÍTICO
    echo ""
    echo -e "${VM}${NG}⚠️  AVISO DE REMOÇÃO DEFINITIVA / PURGE ⚠️${SC}"
    echo -e "Programa selecionado: ${CI}${NG}$alvo${SC} (v$versao_alvo)"
    echo ""
    echo -e "${AM}Esta operação irá remover PERMANENTEMENTE:"
    echo -e "  • Todos os arquivos binários e bibliotecas do programa"
    echo -e "  • Arquivos de configuração globais do sistema (/etc)"
    echo -e "  • Dependências órfãs não utilizadas por outros apps"
    echo -e "  • Opção de limpar arquivos de dados/cache na sua pasta pessoal (~/)"
    echo -e ""
    echo -e "  Esta ação NÃO PODE ser desfeita.${SC}"
    echo ""
    echo -e "----------------------------------------------------------------------"
    echo -e "  Digite ${VM}${NG}sim${SC} para confirmar a remoção permanente"
    echo -e "  ${CI}m)${SC}   Voltar ao menu principal"
    echo -e "  ${AM}0)${SC}   Sair"
    echo ""
    read -rp "Confirmação: " confirmacao || true

    case "$confirmacao" in
        0|q|Q) sair ;;
        m|M)   return 0 ;;
    esac

    if [[ "${confirmacao,,}" != "sim" ]]; then
        echo -e "\n${VD}Operação cancelada. O programa '$alvo' foi mantido intacto.${SC}\n"
        sleep 2
        return 0
    fi

    echo ""
    echo -e "${VM}Iniciando a remoção definitiva de '$alvo'...${SC}"
    echo -e "Será solicitada a senha do sistema (sudo) caso necessário.\n"

    local log_erro
    log_erro=$(mktemp /tmp/deb-purge-XXXXXX.log)

    if sudo apt-get purge -y "$alvo" 2>"$log_erro" && sudo apt-get autoremove --purge -y 2>>"$log_erro"; then
        # Verifica se realmente foi removido
        if ! dpkg -s "$alvo" &>/dev/null; then
            echo ""
            echo -e "${VD}${NG}======================================================================${SC}"
            echo -e "${VD}${NG}  ✓ DESINSTALAÇÃO DO SISTEMA CONCLUÍDA COM SUCESSO                  ${SC}"
            echo -e "${VD}${NG}======================================================================${SC}"
            echo ""
            echo -e "  Programa:  ${CI}${NG}$alvo${SC} (v$versao_alvo)"
            echo -e "  Status:    ${VD}Removido do sistema${SC}"
            echo -e ""
            echo -e "  O que foi feito:"
            echo -e "    ${VD}✓${SC} Binários e bibliotecas removidos"
            echo -e "    ${VD}✓${SC} Configurações do sistema apagadas (/etc)"
            echo -e "    ${VD}✓${SC} Dependências órfãs limpas (autoremove)"

            # Busca e remoção de dados do usuário na Home
            local dados_usuario=()
            while IFS= read -r item; do
                [[ -n "$item" ]] && dados_usuario+=("$item")
            done < <(encontrar_dados_usuario "$alvo")

            if ((${#dados_usuario[@]} > 0)); then
                echo ""
                echo -e "${AM}${NG}----------------------------------------------------------------------${SC}"
                echo -e "${AM}${NG}  ARQUIVOS RESIDUAIS DO USUÁRIO ENCONTRADOS NA HOME (~/):           ${SC}"
                echo -e "${AM}${NG}----------------------------------------------------------------------${SC}"
                for d in "${dados_usuario[@]}"; do
                    echo -e "    ${CI}• $d${SC}"
                done
                echo ""
                echo -e "${AM}Deseja remover também esses arquivos/configurações do usuário?${SC}"
                echo -e "Digite ${VM}${NG}sim${SC} para apagar ou qualquer outra tecla para manter:"
                read -rp "Opção: " apagar_home || true

                if [[ "${apagar_home,,}" == "sim" ]]; then
                    for d in "${dados_usuario[@]}"; do
                        rm -rf "$d" 2>/dev/null || true
                    done
                    echo -e "\n  ${VD}✓ Arquivos residuais do usuário removidos com sucesso!${SC}"
                else
                    echo -e "\n  ${AM}Os arquivos de configuração do usuário foram preservados.${SC}"
                fi
            else
                echo -e "    ${VD}✓${SC} Nenhum dado residual adicional encontrado na pasta do usuário."
            fi

        else
            echo ""
            echo -e "${AM}${NG}======================================================================${SC}"
            echo -e "${AM}${NG}  ⚠ REMOÇÃO PARCIAL                                                  ${SC}"
            echo -e "${AM}${NG}======================================================================${SC}"
            echo ""
            echo -e "  Programa:  ${CI}${NG}$alvo${SC}"
            echo -e "  Status:    ${AM}Ainda detectado no sistema${SC}"
            echo ""
            echo -e "  ${AM}Sugestão:${SC} Execute manualmente no terminal:"
            echo -e "    ${CI}sudo dpkg --purge --force-all $alvo${SC}"
        fi
    else
        local erro_msg
        erro_msg=$(cat "$log_erro" 2>/dev/null)

        echo ""
        echo -e "${VM}${NG}======================================================================${SC}"
        echo -e "${VM}${NG}  ✗ ERRO NA DESINSTALAÇÃO                                             ${SC}"
        echo -e "${VM}${NG}======================================================================${SC}"
        echo ""
        echo -e "  Programa:  ${CI}${NG}$alvo${SC} (v$versao_alvo)"
        echo -e "  Status:    ${VM}Falha ao desinstalar${SC}"

        # Diagnóstico e sugestão baseados no tipo de erro
        if echo "$erro_msg" | grep -qi "permission denied\|permissão negada"; then
            echo ""
            echo -e "  ${AM}Causa:${SC} Permissão insuficiente."
            echo -e "  ${AM}Sugestão:${SC} Verifique se seu usuário tem permissão de sudo:"
            echo -e "    ${CI}sudo -v${SC}"
        elif echo "$erro_msg" | grep -qi "lock\|travado\|bloqueado"; then
            echo ""
            echo -e "  ${AM}Causa:${SC} Outro gerenciador de pacotes está em execução."
            echo -e "  ${AM}Sugestão:${SC} Feche a Loja de Apps ou outro atualizador e tente novamente."
            echo -e "    Se persistir, execute:"
            echo -e "    ${CI}sudo rm /var/lib/dpkg/lock-frontend && sudo dpkg --configure -a${SC}"
        elif echo "$erro_msg" | grep -qi "dependency\|dependência\|depende"; then
            echo ""
            echo -e "  ${AM}Causa:${SC} Conflito de dependências com outros pacotes."
            echo -e "  ${AM}Sugestão:${SC} Tente corrigir as dependências primeiro:"
            echo -e "    ${CI}sudo apt-get install -f && sudo apt-get purge $alvo${SC}"
        elif echo "$erro_msg" | grep -qi "not found\|não encontrado\|unable to locate"; then
            echo ""
            echo -e "  ${AM}Causa:${SC} Pacote não encontrado na base de dados."
            echo -e "  ${AM}Sugestão:${SC} O pacote pode já ter sido removido. Verifique:"
            echo -e "    ${CI}dpkg -s $alvo${SC}"
        else
            echo ""
            echo -e "  ${AM}Detalhes do erro:${SC}"
            echo "$erro_msg" | head -n 5 | while read -r linha; do
                echo -e "    ${VM}$linha${SC}"
            done
            echo ""
            echo -e "  ${AM}Sugestão geral:${SC} Tente reparar o sistema de pacotes:"
            echo -e "    ${CI}sudo dpkg --configure -a && sudo apt-get install -f${SC}"
        fi
    fi

    rm -f "$log_erro"

    echo ""
    echo -e "----------------------------------------------------------------------"
    echo -e "  ${CI}m)${SC} Voltar ao menu principal"
    echo -e "  ${AM}0)${SC} Sair"
    echo ""
    read -rp "Opção: " opt || true
    case "$opt" in
        0|q|Q) sair ;;
        *)     return 0 ;;
    esac
}

sair() {
    limpar
    echo -e "${VD}Gerenciador encerrado.${SC}"
    exit 0
}

# Menu principal
menu_principal() {
    while true; do
        limpar
        echo -e "${AZ}${NG}======================================================================${SC}"
        echo -e "${AZ}${NG}             GERENCIADOR DE DESINSTALAÇÃO DE .DEB (CLI)               ${SC}"
        echo -e "${AZ}${NG}======================================================================${SC}"
        echo ""
        echo -e "  ${CI}1)${SC} Listar programas .deb instalados"
        echo -e "  ${VM}2)${SC} Desinstalar programa permanentemente (Purge)"
        echo -e "  ${AM}0)${SC} Sair"
        echo ""
        echo -e "----------------------------------------------------------------------"
        read -rp "Opção [0-2]: " opt || true

        case "$opt" in
            1) listar_pacotes ;;
            2) desinstalar_pacote ;;
            0|q|Q) sair ;;
            *)
                echo -e "\n${VM}Opção inválida!${SC}"
                sleep 1
                ;;
        esac
    done
}

# Parâmetros de linha de comando
case "${1:-}" in
    --list|-l)   listar_pacotes ; exit 0 ;;
    --remove|-r) desinstalar_pacote ; exit 0 ;;
    *)           menu_principal ;;
esac
